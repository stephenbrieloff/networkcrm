import React, { useState, useEffect } from 'react';
import { 
  Users, 
  UserPlus, 
  MessageSquare, 
  Calendar,
  Smartphone,
  TrendingUp,
  Activity,
  RefreshCw
} from 'lucide-react';
import StatCard from './components/StatCard';
import TrendChart from './components/TrendChart';
import ActivityBreakdown from './components/ActivityBreakdown';
import './App.css';

const API_BASE_URL = process.env.REACT_APP_API_URL || '/api';

function App() {
  const [stats, setStats] = useState(null);
  const [trends, setTrends] = useState({});
  const [activity, setActivity] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedPeriod, setSelectedPeriod] = useState('30d');
  const [lastUpdated, setLastUpdated] = useState(new Date());

  useEffect(() => {
    fetchDashboardData();
    // Auto-refresh every 5 minutes
    const interval = setInterval(fetchDashboardData, 5 * 60 * 1000);
    return () => clearInterval(interval);
  }, [selectedPeriod]);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [statsRes, trendsRes, activityRes] = await Promise.all([
        fetch(`${API_BASE_URL}/dashboard/stats?period=${selectedPeriod}`),
        fetch(`${API_BASE_URL}/dashboard/trends?period=${selectedPeriod}&metric=users`),
        fetch(`${API_BASE_URL}/dashboard/activity?period=${selectedPeriod}`)
      ]);

      if (!statsRes.ok || !trendsRes.ok || !activityRes.ok) {
        throw new Error('Failed to fetch dashboard data');
      }

      const [statsData, trendsData, activityData] = await Promise.all([
        statsRes.json(),
        trendsRes.json(),
        activityRes.json()
      ]);

      setStats(statsData);
      
      // Fetch additional trend data
      const contactTrends = await fetch(`${API_BASE_URL}/dashboard/trends?period=${selectedPeriod}&metric=contacts`);
      const followUpTrends = await fetch(`${API_BASE_URL}/dashboard/trends?period=${selectedPeriod}&metric=followups`);
      const activeUserTrends = await fetch(`${API_BASE_URL}/dashboard/trends?period=${selectedPeriod}&metric=active_users`);

      const [contactTrendsData, followUpTrendsData, activeUserTrendsData] = await Promise.all([
        contactTrends.json(),
        followUpTrends.json(),
        activeUserTrends.json()
      ]);

      setTrends({
        users: trendsData.data,
        contacts: contactTrendsData.data,
        followups: followUpTrendsData.data,
        activeUsers: activeUserTrendsData.data
      });

      setActivity(activityData.activities);
      setLastUpdated(new Date());

    } catch (err) {
      setError(err.message);
      console.error('Dashboard data fetch error:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = () => {
    fetchDashboardData();
  };

  const handlePeriodChange = (period) => {
    setSelectedPeriod(period);
  };

  if (loading && !stats) {
    return (
      <div className="loading-container">
        <div className="loading-spinner">
          <RefreshCw className="animate-spin" size={32} />
          <p>Loading dashboard data...</p>
        </div>
      </div>
    );
  }

  if (error && !stats) {
    return (
      <div className="error-container">
        <div className="error-content">
          <h2>Error Loading Dashboard</h2>
          <p>{error}</p>
          <button onClick={handleRefresh} className="retry-button">
            <RefreshCw size={16} />
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <div className="header-title">
            <Smartphone className="header-icon" />
            <div>
              <h1>Network CRM Admin Dashboard</h1>
              <p className="header-subtitle">Product Usage & Analytics</p>
            </div>
          </div>
          
          <div className="header-controls">
            <div className="period-selector">
              {['7d', '30d', '90d'].map(period => (
                <button
                  key={period}
                  className={`period-button ${selectedPeriod === period ? 'active' : ''}`}
                  onClick={() => handlePeriodChange(period)}
                >
                  {period}
                </button>
              ))}
            </div>
            
            <button 
              onClick={handleRefresh} 
              className="refresh-button"
              disabled={loading}
            >
              <RefreshCw size={16} className={loading ? 'animate-spin' : ''} />
              Refresh
            </button>
          </div>
        </div>

        <div className="last-updated">
          Last updated: {lastUpdated.toLocaleString()}
        </div>
      </header>

      <main className="app-main">
        {error && (
          <div className="error-banner">
            <p>⚠️ {error}</p>
          </div>
        )}

        {stats && (
          <>
            {/* Key Metrics */}
            <section className="metrics-section">
              <h2 className="section-title">Key Metrics</h2>
              <div className="stats-grid">
                <StatCard
                  title="Total Users"
                  value={stats.users.total}
                  icon={<Users />}
                  subtitle={`${stats.users.active} active in ${selectedPeriod}`}
                  color="blue"
                  trend={stats.users.new > 0 ? `+${stats.users.new} new` : 'No new users'}
                />
                
                <StatCard
                  title="Contacts Added"
                  value={stats.contacts.total}
                  icon={<UserPlus />}
                  subtitle="Total across all users"
                  color="green"
                />
                
                <StatCard
                  title="Follow-ups Recommended"
                  value={stats.followUps.total}
                  icon={<Calendar />}
                  subtitle="Networking reminders set"
                  color="orange"
                />
                
                <StatCard
                  title="Voice Notes"
                  value={stats.voiceNotes.total}
                  icon={<MessageSquare />}
                  subtitle="Audio memos recorded"
                  color="purple"
                />
                
                <StatCard
                  title="Template Usage"
                  value={stats.templates.total}
                  icon={<MessageSquare />}
                  subtitle="Message templates used"
                  color="pink"
                />
                
                <StatCard
                  title="Recent Activity"
                  value={stats.events.recent}
                  icon={<Activity />}
                  subtitle={`Events in ${selectedPeriod}`}
                  color="indigo"
                />
              </div>
            </section>

            {/* Trends Over Time */}
            <section className="charts-section">
              <h2 className="section-title">Trends Over Time</h2>
              <div className="charts-grid">
                <TrendChart
                  title="New Users"
                  data={trends.users || []}
                  color="#3B82F6"
                  period={selectedPeriod}
                />
                
                <TrendChart
                  title="Contacts Added"
                  data={trends.contacts || []}
                  color="#10B981"
                  period={selectedPeriod}
                />
                
                <TrendChart
                  title="Follow-ups Set"
                  data={trends.followups || []}
                  color="#F59E0B"
                  period={selectedPeriod}
                />
                
                <TrendChart
                  title="Active Users"
                  data={trends.activeUsers || []}
                  color="#8B5CF6"
                  period={selectedPeriod}
                />
              </div>
            </section>

            {/* Activity Breakdown */}
            <section className="activity-section">
              <h2 className="section-title">User Activity Breakdown</h2>
              <ActivityBreakdown data={activity} period={selectedPeriod} />
            </section>
          </>
        )}
      </main>
    </div>
  );
}

export default App;