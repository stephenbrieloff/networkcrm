const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');
require('dotenv').config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://localhost:3001'], 
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Auth middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Helper function to generate tokens
const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// ===================
// AUTH ROUTES
// ===================

// Register
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, firstName, lastName } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        firstName: firstName || null,
        lastName: lastName || null
      }
    });

    const token = generateToken(user.id);

    res.status(201).json({
      message: 'User created successfully',
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName
      }
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const isValidPassword = await bcrypt.compare(password, user.password);

    if (!isValidPassword) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const token = generateToken(user.id);

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===================
// CONTACT ROUTES
// ===================

// Get all contacts (with search)
app.get('/api/contacts', authenticateToken, async (req, res) => {
  try {
    const { search, limit = 100 } = req.query;
    const userId = req.user.userId;

    let where = { userId };

    if (search) {
      where.OR = [
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { company: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { notes: { contains: search, mode: 'insensitive' } }
      ];
    }

    const contacts = await prisma.contact.findMany({
      where,
      take: parseInt(limit),
      orderBy: { updatedAt: 'desc' },
      include: {
        reminders: {
          where: { completed: false },
          orderBy: { reminderDate: 'asc' }
        }
      }
    });

    res.json({ contacts });
  } catch (error) {
    console.error('Get contacts error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get single contact
app.get('/api/contacts/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const contact = await prisma.contact.findFirst({
      where: { id, userId },
      include: {
        reminders: {
          orderBy: { reminderDate: 'asc' }
        }
      }
    });

    if (!contact) {
      return res.status(404).json({ error: 'Contact not found' });
    }

    res.json({ contact });
  } catch (error) {
    console.error('Get contact error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create contact
app.post('/api/contacts', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const {
      firstName,
      lastName,
      company,
      jobTitle,
      email,
      phone,
      linkedinUrl,
      metAt,
      metDate,
      notes,
      tags = []
    } = req.body;

    if (!firstName) {
      return res.status(400).json({ error: 'First name is required' });
    }

    const contact = await prisma.contact.create({
      data: {
        userId,
        firstName,
        lastName,
        company,
        jobTitle,
        email,
        phone,
        linkedinUrl,
        metAt,
        metDate: metDate ? new Date(metDate) : null,
        notes,
        tags
      },
      include: {
        reminders: {
          where: { completed: false },
          orderBy: { reminderDate: 'asc' }
        }
      }
    });

    res.status(201).json({ contact });
  } catch (error) {
    console.error('Create contact error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update contact
app.put('/api/contacts/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const updateData = { ...req.body };

    // Handle metDate conversion
    if (updateData.metDate) {
      updateData.metDate = new Date(updateData.metDate);
    }

    const contact = await prisma.contact.updateMany({
      where: { id, userId },
      data: updateData
    });

    if (contact.count === 0) {
      return res.status(404).json({ error: 'Contact not found' });
    }

    // Fetch updated contact with reminders
    const updatedContact = await prisma.contact.findFirst({
      where: { id, userId },
      include: {
        reminders: {
          where: { completed: false },
          orderBy: { reminderDate: 'asc' }
        }
      }
    });

    res.json({ contact: updatedContact });
  } catch (error) {
    console.error('Update contact error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete contact
app.delete('/api/contacts/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const deleteResult = await prisma.contact.deleteMany({
      where: { id, userId }
    });

    if (deleteResult.count === 0) {
      return res.status(404).json({ error: 'Contact not found' });
    }

    res.json({ message: 'Contact deleted successfully' });
  } catch (error) {
    console.error('Delete contact error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===================
// REMINDER ROUTES
// ===================

// Get reminders (with filters)
app.get('/api/reminders', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { contactId, completed = 'false', upcoming = 'false' } = req.query;

    let where = { userId };

    if (contactId) {
      where.contactId = contactId;
    }

    if (completed !== 'all') {
      where.completed = completed === 'true';
    }

    if (upcoming === 'true') {
      where.reminderDate = {
        gte: new Date(),
        lte: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // Next 7 days
      };
    }

    const reminders = await prisma.reminder.findMany({
      where,
      include: {
        contact: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            company: true
          }
        }
      },
      orderBy: { reminderDate: 'asc' }
    });

    res.json({ reminders });
  } catch (error) {
    console.error('Get reminders error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create reminder
app.post('/api/reminders', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    const { contactId, title, description, reminderDate } = req.body;

    if (!title || !reminderDate) {
      return res.status(400).json({ error: 'Title and reminder date are required' });
    }

    // Verify contact belongs to user if contactId provided
    if (contactId) {
      const contact = await prisma.contact.findFirst({
        where: { id: contactId, userId }
      });
      if (!contact) {
        return res.status(400).json({ error: 'Invalid contact ID' });
      }
    }

    const reminder = await prisma.reminder.create({
      data: {
        userId,
        contactId,
        title,
        description,
        reminderDate: new Date(reminderDate)
      },
      include: {
        contact: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            company: true
          }
        }
      }
    });

    res.status(201).json({ reminder });
  } catch (error) {
    console.error('Create reminder error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update reminder
app.put('/api/reminders/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    const updateData = { ...req.body };

    if (updateData.reminderDate) {
      updateData.reminderDate = new Date(updateData.reminderDate);
    }

    if (updateData.completed && !updateData.completedAt) {
      updateData.completedAt = new Date();
    }

    const reminder = await prisma.reminder.updateMany({
      where: { id, userId },
      data: updateData
    });

    if (reminder.count === 0) {
      return res.status(404).json({ error: 'Reminder not found' });
    }

    const updatedReminder = await prisma.reminder.findFirst({
      where: { id, userId },
      include: {
        contact: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            company: true
          }
        }
      }
    });

    res.json({ reminder: updatedReminder });
  } catch (error) {
    console.error('Update reminder error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Complete reminder
app.post('/api/reminders/:id/complete', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const reminder = await prisma.reminder.updateMany({
      where: { id, userId },
      data: {
        completed: true,
        completedAt: new Date()
      }
    });

    if (reminder.count === 0) {
      return res.status(404).json({ error: 'Reminder not found' });
    }

    res.json({ message: 'Reminder completed successfully' });
  } catch (error) {
    console.error('Complete reminder error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete reminder
app.delete('/api/reminders/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    const deleteResult = await prisma.reminder.deleteMany({
      where: { id, userId }
    });

    if (deleteResult.count === 0) {
      return res.status(404).json({ error: 'Reminder not found' });
    }

    res.json({ message: 'Reminder deleted successfully' });
  } catch (error) {
    console.error('Delete reminder error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// ===================
// HEALTH CHECK
// ===================

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});