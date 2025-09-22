# Network CRM Backend

A simple, fast backend API for the Network CRM iOS app. Built with Node.js, Express, and PostgreSQL.

## Quick Start

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up the database:**
   ```bash
   npm run db:push
   ```

3. **Generate Prisma client:**
   ```bash
   npm run db:generate
   ```

4. **Start the server:**
   ```bash
   npm run dev
   ```

The server will run on `http://localhost:3001`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create new user
- `POST /api/auth/login` - Login user

### Contacts (All require authentication)
- `GET /api/contacts` - List contacts (supports `?search=term` and `?limit=100`)
- `POST /api/contacts` - Create new contact
- `GET /api/contacts/:id` - Get single contact
- `PUT /api/contacts/:id` - Update contact
- `DELETE /api/contacts/:id` - Delete contact

### Reminders (All require authentication)
- `GET /api/reminders` - List reminders (supports filters)
- `POST /api/reminders` - Create reminder
- `PUT /api/reminders/:id` - Update reminder
- `POST /api/reminders/:id/complete` - Mark reminder as complete
- `DELETE /api/reminders/:id` - Delete reminder

### Health Check
- `GET /api/health` - Server status

## Authentication

Include the JWT token in the Authorization header:
```
Authorization: Bearer your_jwt_token_here
```

## Example Requests

### Create a Contact
```bash
curl -X POST http://localhost:3001/api/contacts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "company": "Tech Corp",
    "email": "john@techcorp.com",
    "metAt": "Tech Conference 2024",
    "tags": ["developer", "frontend"]
  }'
```

### Search Contacts
```bash
curl "http://localhost:3001/api/contacts?search=john" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Create a Reminder
```bash
curl -X POST http://localhost:3001/api/reminders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contactId": "contact_id_here",
    "title": "Follow up on project discussion",
    "reminderDate": "2024-01-15T10:00:00Z"
  }'
```

## Database Schema

### User
- `id`, `email`, `password`, `firstName`, `lastName`
- `createdAt`, `updatedAt`

### Contact
- `id`, `userId`, `firstName`, `lastName`, `company`, `jobTitle`
- `email`, `phone`, `linkedinUrl`, `metAt`, `metDate`
- `notes`, `tags[]`, `createdAt`, `updatedAt`

### Reminder
- `id`, `userId`, `contactId`, `title`, `description`
- `reminderDate`, `completed`, `completedAt`
- `createdAt`, `updatedAt`

## Environment Variables

```env
DATABASE_URL="your_postgres_connection_string"
JWT_SECRET="your_jwt_secret_key"
PORT=3001
NODE_ENV="development"
```

## Production Deployment

1. Set environment variables
2. Run `npm run db:migrate` for production database
3. Use `npm start` instead of `npm run dev`
4. Consider using PM2 or similar for process management

## Features

✅ JWT Authentication  
✅ Contact Management  
✅ Reminder System  
✅ Search Functionality  
✅ Data Validation  
✅ Error Handling  
✅ CORS Support for iOS  
✅ Automatic timestamps  
✅ Relationship management  

## iOS Integration Notes

- Server runs on port 3001 (iOS app should use `http://localhost:3001`)
- CORS configured for local development
- All endpoints return JSON
- Timestamps in ISO 8601 format
- Search supports partial matches across multiple fields