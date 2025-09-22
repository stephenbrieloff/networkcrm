# NetworkCRM

A modern, web-based Customer Relationship Management system designed for network professionals. Transforming networking-avoiders into networking champions by making relationship management effortless.

## ✨ Key Features

- **5-Second Rule**: Every core action completable in 5 seconds or less
- **Instant Contact Creation**: Add contacts with minimal friction
- **Smart Search**: Find contacts instantly as you type
- **Follow-Up Reminders**: Never miss a networking opportunity
- **Clean Web Interface**: Modern, responsive design that works everywhere

## 🏗️ Architecture

- **Frontend**: Next.js 15 + React + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + Prisma + PostgreSQL
- **Authentication**: JWT-based authentication
- **Database**: PostgreSQL with Prisma ORM

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL database
- npm or yarn

### 1. Clone and Setup
```bash
git clone https://github.com/stephenbrieloff/networkcrm.git
cd networkcrm
```

### 2. Backend Setup
```bash
cd backend
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your database URL and JWT secret

# Setup database
npm run db:push

# Start backend server
npm run dev
```

### 3. Frontend Setup
```bash
cd ../frontend
npm install

# Start frontend development server
npm run dev
```

### 4. Access Application
- Web App: http://localhost:3000
- API: http://localhost:3001

## 🛠️ Development

### Run Full Stack
```bash
cd frontend
npm run dev:full  # Starts both frontend and backend
```

### Available Scripts

#### Frontend
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Lint code
- `npm run type-check` - TypeScript type checking

#### Backend
- `npm run dev` - Start development server with nodemon
- `npm run start` - Start production server
- `npm run db:generate` - Generate Prisma client
- `npm run db:push` - Push schema to database
- `npm run db:migrate` - Create and run migrations

## 📊 Project Status

**✅ Phase 1 Complete - MVP Features**
- Super simple contact addition (< 5 seconds)
- Contact list with instant search
- Contact management (view, edit, delete)
- Clean, responsive web interface
- JWT authentication
- Follow-up reminder system

## 🎯 Core Philosophy

1. **5-Second Rule**: Every core action must complete in under 5 seconds
2. **Instant Capture**: Minimize friction for adding contacts
3. **Zero Configuration**: Works perfectly out of the box
4. **Proactive Intelligence**: App suggests actions, users don't have to think
5. **Web-First Excellence**: Leverage modern web platform capabilities

## 🔧 Tech Stack Details

### Frontend
- **Next.js 15**: React framework with App Router
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first styling
- **Heroicons**: Beautiful SVG icons
- **Headless UI**: Accessible UI components
- **Axios**: HTTP client for API calls
- **Date-fns**: Date manipulation utilities

### Backend
- **Node.js**: JavaScript runtime
- **Express**: Web framework
- **Prisma**: Next-generation ORM
- **PostgreSQL**: Robust relational database
- **JWT**: Secure authentication
- **bcryptjs**: Password hashing
- **CORS**: Cross-origin resource sharing

## 📝 API Documentation

The API provides endpoints for:
- Authentication (register, login)
- Contact management (CRUD operations)
- Search and filtering
- Follow-up reminders
- User management

See [backend/README.md](./backend/README.md) for detailed API documentation.

## 🚢 Deployment

### Frontend (Vercel - Recommended)
```bash
npm run build
# Deploy to Vercel, Netlify, or any static hosting
```

### Backend (Railway, Render, or Docker)
```bash
# Set environment variables
# Deploy to your preferred platform
```

## 🤝 Contributing

This project focuses on simplicity and speed. When contributing:

1. Prioritize user experience over technical complexity
2. Always consider the 5-second rule for new features
3. Use modern web standards and accessibility best practices
4. Focus on reducing friction at every interaction point
5. Test on multiple devices and browsers

## 📄 License

MIT License - see LICENSE file for details.

## 🎯 Target User

"The Reluctant Networker" - professionals who find networking overwhelming but recognize its importance. This tool makes relationship management so simple that networking becomes natural and effortless.
