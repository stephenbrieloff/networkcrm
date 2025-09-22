import React from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

const StatCard = ({ title, value, icon, subtitle, color = 'blue', trend, className = '' }) => {
  const formatNumber = (num) => {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num?.toLocaleString() || '0';
  };

  const getTrendColor = (trend) => {
    if (!trend) return '';
    const trendStr = trend.toString().toLowerCase();
    if (trendStr.includes('+') || trendStr.includes('increase') || trendStr.includes('up')) {
      return 'text-green-600';
    }
    if (trendStr.includes('-') || trendStr.includes('decrease') || trendStr.includes('down')) {
      return 'text-red-600';
    }
    return 'text-gray-600';
  };

  const getTrendIcon = (trend) => {
    if (!trend) return null;
    const trendStr = trend.toString().toLowerCase();
    if (trendStr.includes('+') || trendStr.includes('increase') || trendStr.includes('up')) {
      return <TrendingUp size={14} className="text-green-600" />;
    }
    if (trendStr.includes('-') || trendStr.includes('decrease') || trendStr.includes('down')) {
      return <TrendingDown size={14} className="text-red-600" />;
    }
    return null;
  };

  const colorVariants = {
    blue: 'border-l-blue-500 bg-blue-50',
    green: 'border-l-green-500 bg-green-50',
    orange: 'border-l-orange-500 bg-orange-50',
    purple: 'border-l-purple-500 bg-purple-50',
    pink: 'border-l-pink-500 bg-pink-50',
    indigo: 'border-l-indigo-500 bg-indigo-50',
    red: 'border-l-red-500 bg-red-50',
  };

  const iconColorVariants = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    orange: 'text-orange-600',
    purple: 'text-purple-600',
    pink: 'text-pink-600',
    indigo: 'text-indigo-600',
    red: 'text-red-600',
  };

  return (
    <div className={`stat-card ${colorVariants[color]} ${className}`}>
      <div className="stat-card-content">
        <div className="stat-card-header">
          <div className={`stat-card-icon ${iconColorVariants[color]}`}>
            {icon}
          </div>
          <div className="stat-card-info">
            <h3 className="stat-card-title">{title}</h3>
            <div className="stat-card-value">{formatNumber(value)}</div>
          </div>
        </div>
        
        <div className="stat-card-footer">
          {subtitle && (
            <p className="stat-card-subtitle">{subtitle}</p>
          )}
          
          {trend && (
            <div className={`stat-card-trend ${getTrendColor(trend)}`}>
              {getTrendIcon(trend)}
              <span>{trend}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default StatCard;