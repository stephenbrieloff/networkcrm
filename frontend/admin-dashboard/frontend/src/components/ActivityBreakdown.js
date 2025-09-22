import React, { useState } from 'react';
import { 
  Users, 
  UserPlus, 
  Bell, 
  Mic, 
  MessageSquare, 
  ChevronDown, 
  ChevronUp,
  Calendar,
  Activity,
  TrendingUp,
  Clock
} from 'lucide-react';
import { format, formatDistanceToNow } from 'date-fns';

const ActivityBreakdown = ({ data, className = '' }) => {
  const [expandedSections, setExpandedSections] = useState({
    overview: true,
    recent: true,
    userBreakdown: false,
    trends: false,
  });

  const toggleSection = (section) => {
    setExpandedSections(prev => ({
      ...prev,
      [section]: !prev[section]
    }));
  };

  // Mock recent activities (in a real app, this would come from the API)
  const recentActivities = [
    {
      id: 1,
      type: 'contact_added',
      description: 'New contact added',
      details: 'John Doe from TechCorp',
      timestamp: new Date(Date.now() - 1000 * 60 * 15), // 15 minutes ago
      icon: UserPlus,
      color: 'text-blue-600'
    },
    {
      id: 2,
      type: 'follow_up_created',
      description: 'Follow-up reminder set',
      details: 'Meeting with Sarah Johnson',
      timestamp: new Date(Date.now() - 1000 * 60 * 45), // 45 minutes ago
      icon: Bell,
      color: 'text-green-600'
    },
    {
      id: 3,
      type: 'voice_note_recorded',
      description: 'Voice note recorded',
      details: 'Notes from conference call',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2), // 2 hours ago
      icon: Mic,
      color: 'text-orange-600'
    },
    {
      id: 4,
      type: 'template_used',
      description: 'Message template used',
      details: 'Follow-up email template',
      timestamp: new Date(Date.now() - 1000 * 60 * 60 * 4), // 4 hours ago
      icon: MessageSquare,
      color: 'text-purple-600'
    },
  ];

  // Calculate activity summary
  const getActivitySummary = () => {
    if (!data) return {};
    
    const totalUsers = data.totalUsers || 0;
    const activeToday = Math.floor(totalUsers * 0.4); // Mock: 40% active today
    const avgSessionTime = '4m 32s'; // Mock data
    const topAction = 'Adding Contacts'; // Mock data
    
    return {
      totalUsers,
      activeToday,
      avgSessionTime,
      topAction,
      engagementRate: totalUsers > 0 ? Math.floor((activeToday / totalUsers) * 100) : 0
    };
  };

  const summary = getActivitySummary();

  // User breakdown data (mock)
  const userBreakdownData = [
    { category: 'Power Users', count: Math.floor((data?.totalUsers || 0) * 0.1), percentage: 10 },
    { category: 'Active Users', count: Math.floor((data?.totalUsers || 0) * 0.3), percentage: 30 },
    { category: 'Casual Users', count: Math.floor((data?.totalUsers || 0) * 0.4), percentage: 40 },
    { category: 'Inactive Users', count: Math.floor((data?.totalUsers || 0) * 0.2), percentage: 20 },
  ];

  if (!data) {
    return (
      <div className={`activity-breakdown ${className}`}>
        <div className="activity-breakdown-header">
          <h3 className="activity-breakdown-title">Activity Breakdown</h3>
        </div>
        <div className="activity-breakdown-empty">
          <p className="text-gray-500 text-center py-8">No activity data available</p>
        </div>
      </div>
    );
  }

  const SectionHeader = ({ title, icon: Icon, isExpanded, onToggle }) => (
    <button
      onClick={onToggle}
      className="w-full flex items-center justify-between p-3 bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors"
    >
      <div className="flex items-center gap-2">
        <Icon size={18} className="text-gray-600" />
        <h4 className="font-medium text-gray-800">{title}</h4>
      </div>
      {isExpanded ? (
        <ChevronUp size={18} className="text-gray-600" />
      ) : (
        <ChevronDown size={18} className="text-gray-600" />
      )}
    </button>
  );

  return (
    <div className={`activity-breakdown ${className}`}>
      <div className="activity-breakdown-header">
        <h3 className="activity-breakdown-title">Activity Breakdown</h3>
      </div>

      <div className="space-y-4">
        {/* Overview Section */}
        <div className="activity-section">
          <SectionHeader
            title="Overview"
            icon={Activity}
            isExpanded={expandedSections.overview}
            onToggle={() => toggleSection('overview')}
          />
          
          {expandedSections.overview && (
            <div className="activity-section-content">
              <div className="grid grid-cols-2 gap-4">
                <div className="activity-metric">
                  <div className="activity-metric-header">
                    <Users size={16} className="text-blue-600" />
                    <span className="activity-metric-label">Total Users</span>
                  </div>
                  <div className="activity-metric-value">{summary.totalUsers.toLocaleString()}</div>
                </div>
                
                <div className="activity-metric">
                  <div className="activity-metric-header">
                    <Activity size={16} className="text-green-600" />
                    <span className="activity-metric-label">Active Today</span>
                  </div>
                  <div className="activity-metric-value">{summary.activeToday.toLocaleString()}</div>
                </div>
                
                <div className="activity-metric">
                  <div className="activity-metric-header">
                    <Clock size={16} className="text-orange-600" />
                    <span className="activity-metric-label">Avg Session</span>
                  </div>
                  <div className="activity-metric-value">{summary.avgSessionTime}</div>
                </div>
                
                <div className="activity-metric">
                  <div className="activity-metric-header">
                    <TrendingUp size={16} className="text-purple-600" />
                    <span className="activity-metric-label">Engagement</span>
                  </div>
                  <div className="activity-metric-value">{summary.engagementRate}%</div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Recent Activities Section */}
        <div className="activity-section">
          <SectionHeader
            title="Recent Activities"
            icon={Clock}
            isExpanded={expandedSections.recent}
            onToggle={() => toggleSection('recent')}
          />
          
          {expandedSections.recent && (
            <div className="activity-section-content">
              <div className="space-y-3">
                {recentActivities.map((activity) => {
                  const Icon = activity.icon;
                  return (
                    <div key={activity.id} className="activity-item">
                      <div className={`activity-item-icon ${activity.color}`}>
                        <Icon size={16} />
                      </div>
                      <div className="activity-item-content">
                        <div className="activity-item-header">
                          <span className="activity-item-title">{activity.description}</span>
                          <span className="activity-item-time">
                            {formatDistanceToNow(activity.timestamp, { addSuffix: true })}
                          </span>
                        </div>
                        <p className="activity-item-details">{activity.details}</p>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        {/* User Breakdown Section */}
        <div className="activity-section">
          <SectionHeader
            title="User Breakdown"
            icon={Users}
            isExpanded={expandedSections.userBreakdown}
            onToggle={() => toggleSection('userBreakdown')}
          />
          
          {expandedSections.userBreakdown && (
            <div className="activity-section-content">
              <div className="space-y-3">
                {userBreakdownData.map((item, index) => (
                  <div key={index} className="user-breakdown-item">
                    <div className="user-breakdown-header">
                      <span className="user-breakdown-category">{item.category}</span>
                      <div className="user-breakdown-stats">
                        <span className="user-breakdown-count">{item.count.toLocaleString()}</span>
                        <span className="user-breakdown-percentage">({item.percentage}%)</span>
                      </div>
                    </div>
                    <div className="user-breakdown-bar">
                      <div 
                        className="user-breakdown-fill"
                        style={{ width: `${item.percentage}%` }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Key Metrics Section */}
        <div className="activity-section">
          <SectionHeader
            title="Key Metrics"
            icon={TrendingUp}
            isExpanded={expandedSections.trends}
            onToggle={() => toggleSection('trends')}
          />
          
          {expandedSections.trends && (
            <div className="activity-section-content">
              <div className="grid grid-cols-1 gap-3">
                <div className="key-metric">
                  <span className="key-metric-label">Most Popular Feature</span>
                  <span className="key-metric-value">{summary.topAction}</span>
                </div>
                
                <div className="key-metric">
                  <span className="key-metric-label">Contacts Added Today</span>
                  <span className="key-metric-value">{data.contactsAdded || 0}</span>
                </div>
                
                <div className="key-metric">
                  <span className="key-metric-label">Follow-ups Created</span>
                  <span className="key-metric-value">{data.followUpsRecommended || 0}</span>
                </div>
                
                <div className="key-metric">
                  <span className="key-metric-label">Voice Notes Recorded</span>
                  <span className="key-metric-value">{data.voiceNotes || 0}</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default ActivityBreakdown;