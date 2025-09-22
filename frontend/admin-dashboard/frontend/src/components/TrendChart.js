import React from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { format } from 'date-fns';

const TrendChart = ({ data, title, height = 300, className = '' }) => {
  // Transform data to ensure proper date formatting for display
  const chartData = data?.map(item => ({
    ...item,
    formattedDate: format(new Date(item.date), 'MMM dd'),
    displayDate: item.date,
  })) || [];

  // Custom tooltip component
  const CustomTooltip = ({ active, payload, label }) => {
    if (active && payload && payload.length) {
      const date = new Date(payload[0]?.payload?.displayDate);
      const formattedDate = format(date, 'MMMM dd, yyyy');
      
      return (
        <div className="bg-white p-3 border border-gray-200 rounded-lg shadow-lg">
          <p className="text-gray-600 text-sm mb-2">{formattedDate}</p>
          {payload.map((entry, index) => (
            <div key={index} className="flex items-center gap-2">
              <div 
                className="w-3 h-3 rounded-full" 
                style={{ backgroundColor: entry.color }}
              />
              <span className="text-sm font-medium capitalize">
                {entry.dataKey.replace(/([A-Z])/g, ' $1').toLowerCase()}:
              </span>
              <span className="text-sm font-bold">{entry.value.toLocaleString()}</span>
            </div>
          ))}
        </div>
      );
    }
    return null;
  };

  // Define colors for different metrics
  const getLineColor = (key) => {
    const colors = {
      contactsAdded: '#3B82F6',      // blue
      followUpsCreated: '#10B981',   // green
      voiceNotesRecorded: '#F59E0B', // amber
      templatesUsed: '#8B5CF6',      // purple
      activeUsers: '#EF4444',        // red
      totalContacts: '#06B6D4',      // cyan
    };
    return colors[key] || '#6B7280'; // default gray
  };

  // Get all metric keys from the data (excluding date fields)
  const metricKeys = chartData.length > 0 
    ? Object.keys(chartData[0]).filter(key => 
        !['date', 'formattedDate', 'displayDate'].includes(key)
      )
    : [];

  if (!chartData || chartData.length === 0) {
    return (
      <div className={`trend-chart ${className}`}>
        <div className="trend-chart-header">
          <h3 className="trend-chart-title">{title}</h3>
        </div>
        <div className="trend-chart-empty">
          <p className="text-gray-500 text-center py-8">No trend data available</p>
        </div>
      </div>
    );
  }

  return (
    <div className={`trend-chart ${className}`}>
      <div className="trend-chart-header">
        <h3 className="trend-chart-title">{title}</h3>
      </div>
      
      <div className="trend-chart-container" style={{ height }}>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart
            data={chartData}
            margin={{
              top: 20,
              right: 30,
              left: 20,
              bottom: 20,
            }}
          >
            <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
            <XAxis 
              dataKey="formattedDate"
              stroke="#6B7280"
              fontSize={12}
              tickLine={false}
              axisLine={false}
            />
            <YAxis 
              stroke="#6B7280"
              fontSize={12}
              tickLine={false}
              axisLine={false}
              tickFormatter={(value) => {
                if (value >= 1000) return `${(value / 1000).toFixed(1)}K`;
                return value;
              }}
            />
            <Tooltip content={<CustomTooltip />} />
            <Legend 
              wrapperStyle={{ paddingTop: '20px' }}
              formatter={(value) => (
                <span style={{ color: '#374151', fontSize: '12px' }}>
                  {value.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase())}
                </span>
              )}
            />
            
            {metricKeys.map((key, index) => (
              <Line
                key={key}
                type="monotone"
                dataKey={key}
                stroke={getLineColor(key)}
                strokeWidth={2}
                dot={{ fill: getLineColor(key), strokeWidth: 2, r: 4 }}
                activeDot={{ r: 6, stroke: getLineColor(key), strokeWidth: 2 }}
                connectNulls={false}
              />
            ))}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default TrendChart;