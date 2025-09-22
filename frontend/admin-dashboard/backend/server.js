const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Logging
app.use(morgan('combined'));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Connect to MongoDB
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/network-crm-admin';
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('📊 Connected to MongoDB'))
.catch(err => console.error('MongoDB connection error:', err));

// Analytics Schema
const analyticsSchema = new mongoose.Schema({
  userId: { type: String, required: true, index: true },
  eventType: { 
    type: String, 
    required: true,
    enum: ['app_open', 'contact_added', 'follow_up_set', 'voice_note_recorded', 'template_used']
  },
  timestamp: { type: Date, default: Date.now, index: true },
  metadata: {
    platform: String,
    appVersion: String,
    contactCount: Number,
    followUpCount: Number,
    templateCategory: String
  }
}, {
  timestamps: true
});

// User Schema for tracking unique users
const userSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  firstSeen: { type: Date, default: Date.now },
  lastSeen: { type: Date, default: Date.now },
  platform: String,
  appVersion: String,
  totalContacts: { type: Number, default: 0 },
  totalFollowUps: { type: Number, default: 0 },
  totalVoiceNotes: { type: Number, default: 0 },
  totalTemplatesUsed: { type: Number, default: 0 }
}, {
  timestamps: true
});

const Analytics = mongoose.model('Analytics', analyticsSchema);
const User = mongoose.model('User', userSchema);

// API Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Network CRM Admin API is running' });
});

// Record analytics event from iOS app
app.post('/api/analytics', async (req, res) => {
  try {
    const { userId, eventType, metadata } = req.body;

    if (!userId || !eventType) {
      return res.status(400).json({ error: 'userId and eventType are required' });
    }

    // Create analytics event
    const event = new Analytics({
      userId,
      eventType,
      metadata: metadata || {}
    });

    await event.save();

    // Update or create user record
    const user = await User.findOneAndUpdate(
      { userId },
      {
        $set: {
          lastSeen: new Date(),
          platform: metadata?.platform,
          appVersion: metadata?.appVersion
        },
        $setOnInsert: { firstSeen: new Date() },
        $inc: getIncrementFields(eventType)
      },
      { upsert: true, new: true }
    );

    res.json({ success: true, message: 'Event recorded' });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to record analytics event' });
  }
});

// Get dashboard statistics
app.get('/api/dashboard/stats', async (req, res) => {
  try {
    const { period = '30d' } = req.query;
    const startDate = getStartDate(period);

    // Get current statistics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({
      lastSeen: { $gte: startDate }
    });

    const totalContacts = await User.aggregate([
      { $group: { _id: null, total: { $sum: '$totalContacts' } } }
    ]);

    const totalFollowUps = await User.aggregate([
      { $group: { _id: null, total: { $sum: '$totalFollowUps' } } }
    ]);

    const totalVoiceNotes = await User.aggregate([
      { $group: { _id: null, total: { $sum: '$totalVoiceNotes' } } }
    ]);

    const totalTemplatesUsed = await User.aggregate([
      { $group: { _id: null, total: { $sum: '$totalTemplatesUsed' } } }
    ]);

    // Get new users in period
    const newUsers = await User.countDocuments({
      firstSeen: { $gte: startDate }
    });

    // Get events in period
    const recentEvents = await Analytics.countDocuments({
      timestamp: { $gte: startDate }
    });

    res.json({
      users: {
        total: totalUsers,
        active: activeUsers,
        new: newUsers
      },
      contacts: {
        total: totalContacts[0]?.total || 0
      },
      followUps: {
        total: totalFollowUps[0]?.total || 0
      },
      voiceNotes: {
        total: totalVoiceNotes[0]?.total || 0
      },
      templates: {
        total: totalTemplatesUsed[0]?.total || 0
      },
      events: {
        recent: recentEvents
      },
      period: period
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard statistics' });
  }
});

// Get trending data over time
app.get('/api/dashboard/trends', async (req, res) => {
  try {
    const { period = '30d', metric = 'users' } = req.query;
    const days = parseInt(period.replace('d', ''));
    
    const trends = await generateTrendData(metric, days);
    
    res.json({
      metric,
      period,
      data: trends
    });
  } catch (error) {
    console.error('Trends error:', error);
    res.status(500).json({ error: 'Failed to fetch trend data' });
  }
});

// Get user activity breakdown
app.get('/api/dashboard/activity', async (req, res) => {
  try {
    const { period = '7d' } = req.query;
    const startDate = getStartDate(period);

    const activity = await Analytics.aggregate([
      { $match: { timestamp: { $gte: startDate } } },
      { $group: { 
          _id: '$eventType', 
          count: { $sum: 1 },
          uniqueUsers: { $addToSet: '$userId' }
        }
      },
      { $project: {
          eventType: '$_id',
          count: 1,
          uniqueUsers: { $size: '$uniqueUsers' },
          _id: 0
        }
      },
      { $sort: { count: -1 } }
    ]);

    res.json({
      period,
      activities: activity
    });
  } catch (error) {
    console.error('Activity error:', error);
    res.status(500).json({ error: 'Failed to fetch activity data' });
  }
});

// Helper functions
function getIncrementFields(eventType) {
  const increments = {};
  
  switch (eventType) {
    case 'contact_added':
      increments.totalContacts = 1;
      break;
    case 'follow_up_set':
      increments.totalFollowUps = 1;
      break;
    case 'voice_note_recorded':
      increments.totalVoiceNotes = 1;
      break;
    case 'template_used':
      increments.totalTemplatesUsed = 1;
      break;
  }
  
  return increments;
}

function getStartDate(period) {
  const days = parseInt(period.replace('d', ''));
  const date = new Date();
  date.setDate(date.getDate() - days);
  date.setHours(0, 0, 0, 0);
  return date;
}

async function generateTrendData(metric, days) {
  const trends = [];
  const today = new Date();
  
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    date.setHours(0, 0, 0, 0);
    
    const nextDate = new Date(date);
    nextDate.setDate(nextDate.getDate() + 1);
    
    let value = 0;
    
    switch (metric) {
      case 'users':
        // New users for this day
        value = await User.countDocuments({
          firstSeen: { $gte: date, $lt: nextDate }
        });
        break;
        
      case 'contacts':
        // Contacts added this day
        value = await Analytics.countDocuments({
          eventType: 'contact_added',
          timestamp: { $gte: date, $lt: nextDate }
        });
        break;
        
      case 'followups':
        // Follow-ups set this day
        value = await Analytics.countDocuments({
          eventType: 'follow_up_set',
          timestamp: { $gte: date, $lt: nextDate }
        });
        break;
        
      case 'active_users':
        // Active users this day
        value = await Analytics.distinct('userId', {
          timestamp: { $gte: date, $lt: nextDate }
        }).then(users => users.length);
        break;
    }
    
    trends.push({
      date: date.toISOString().split('T')[0],
      value: value
    });
  }
  
  return trends;
}

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(PORT, () => {
  console.log(`🚀 Network CRM Admin Server running on port ${PORT}`);
  console.log(`📊 Dashboard available at http://localhost:${PORT}`);
});