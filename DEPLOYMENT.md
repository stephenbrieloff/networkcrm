# NetworkCRM Deployment Guide

## 🚀 Deploying to Vercel

### Prerequisites
1. Vercel account (sign up at [vercel.com](https://vercel.com))
2. PostgreSQL database (we recommend [Neon](https://neon.tech) or [Supabase](https://supabase.com))
3. GitHub repository (✅ already done!)

### Step 1: Deploy Backend API

1. **Go to [vercel.com](https://vercel.com) and click "New Project"**
2. **Import your GitHub repository: `stephenbrieloff/networkcrm`**
3. **Configure the backend:**
   - **Root Directory**: `backend`
   - **Framework Preset**: Other
   - **Build Command**: `npm install && npx prisma generate`
   - **Output Directory**: (leave empty)
   - **Install Command**: `npm install`

4. **Add Environment Variables:**
   ```
   DATABASE_URL=your-postgresql-connection-string
   JWT_SECRET=your-super-secret-jwt-key-min-32-chars
   PORT=3001
   ```

5. **Click "Deploy"**

### Step 2: Deploy Frontend

1. **Create another new project in Vercel**
2. **Import the same GitHub repository: `stephenbrieloff/networkcrm`**
3. **Configure the frontend:**
   - **Root Directory**: `frontend`
   - **Framework Preset**: Next.js
   - **Build Command**: (auto-detected)
   - **Output Directory**: (auto-detected)
   - **Install Command**: `npm install`

4. **Add Environment Variables:**
   ```
   NEXT_PUBLIC_API_URL=https://your-backend-url.vercel.app/api
   ```
   (Use the URL from your backend deployment in Step 1)

5. **Click "Deploy"**

### Step 3: Update Frontend Environment

After both deployments are complete:

1. **Get your backend URL** from the Vercel dashboard
2. **Update the frontend environment variable:**
   - Go to your frontend project in Vercel
   - Settings → Environment Variables
   - Update `NEXT_PUBLIC_API_URL` with your actual backend URL

3. **Redeploy the frontend** to apply the changes

## 🗄️ Database Setup

### Option A: Neon (Recommended)
1. Sign up at [neon.tech](https://neon.tech)
2. Create a new database
3. Copy the connection string
4. Add it as `DATABASE_URL` in your backend environment variables

### Option B: Supabase
1. Sign up at [supabase.com](https://supabase.com)
2. Create a new project
3. Go to Settings → Database
4. Copy the connection string
5. Add it as `DATABASE_URL` in your backend environment variables

### Option C: Railway
1. Sign up at [railway.app](https://railway.app)
2. Create a PostgreSQL database
3. Copy the connection string
4. Add it as `DATABASE_URL` in your backend environment variables

## 🔑 Environment Variables Checklist

### Backend Environment Variables:
- ✅ `DATABASE_URL` - Your PostgreSQL connection string
- ✅ `JWT_SECRET` - A secure random string (min 32 characters)
- ✅ `PORT` - Set to 3001

### Frontend Environment Variables:
- ✅ `NEXT_PUBLIC_API_URL` - Your deployed backend URL + `/api`

## 🎯 After Deployment

1. **Test your deployed app**
2. **Set up custom domain** (optional)
3. **Enable automatic deployments** from GitHub
4. **Monitor performance** in Vercel dashboard

## 🚨 Troubleshooting

### Common Issues:
- **"Module not found"**: Make sure `package.json` is in the correct root directory
- **Database connection errors**: Verify your `DATABASE_URL` is correct
- **CORS errors**: Check that your API URL environment variable is set correctly
- **Build fails**: Check the build logs in Vercel dashboard

### Getting Help:
- Check Vercel documentation: [vercel.com/docs](https://vercel.com/docs)
- Review build logs in the Vercel dashboard
- Check GitHub issues for the project

## 🎉 Success!

Once deployed, your NetworkCRM will be accessible at:
- **Frontend**: `https://your-frontend.vercel.app`
- **Backend**: `https://your-backend.vercel.app`

The app will automatically redeploy when you push changes to GitHub!