'use client';

import { useState } from 'react';
import { Contact } from '@/types';
import { formatDistanceToNow } from 'date-fns';
import { 
  MagnifyingGlassIcon, 
  TrashIcon,
  BuildingOfficeIcon,
  BellIcon,
  UserGroupIcon
} from '@heroicons/react/24/outline';
import { apiService } from '@/lib/api';

interface ContactListProps {
  contacts: Contact[];
  onSearch: (query: string) => void;
  onContactDeleted: () => void;
  searchQuery: string;
}

export default function ContactList({ contacts, onSearch, onContactDeleted, searchQuery }: ContactListProps) {
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const handleDelete = async (contact: Contact) => {
    if (deletingId) return;
    
    if (!confirm(`Are you sure you want to delete ${contact.firstName} ${contact.lastName}?`)) {
      return;
    }

    try {
      setDeletingId(contact.id);
      await apiService.deleteContact(contact.id);
      onContactDeleted();
    } catch (error) {
      console.error('Error deleting contact:', error);
      alert('Failed to delete contact');
    } finally {
      setDeletingId(null);
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInHours = (now.getTime() - date.getTime()) / (1000 * 3600);
    
    if (diffInHours < 24) {
      return 'Today';
    } else if (diffInHours < 48) {
      return 'Yesterday';
    } else if (diffInHours < 168) { // 7 days
      return date.toLocaleDateString('en-US', { weekday: 'long' });
    } else {
      return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    }
  };

  if (contacts.length === 0 && !searchQuery) {
    return <EmptyState />;
  }

  return (
    <div className="bg-white rounded-lg shadow">
      {/* Search Header */}
      <div className="p-6 border-b border-gray-200">
        <div className="relative">
          <MagnifyingGlassIcon className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input
            type="text"
            placeholder="Search contacts..."
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          />
        </div>
        
        {contacts.length > 0 && (
          <p className="mt-3 text-sm text-gray-600">
            {contacts.length} contact{contacts.length !== 1 ? 's' : ''}
            {searchQuery && ` matching "${searchQuery}"`}
          </p>
        )}
      </div>

      {/* Contact List */}
      <div className="divide-y divide-gray-200">
        {contacts.length === 0 && searchQuery ? (
          <div className="p-12 text-center">
            <MagnifyingGlassIcon className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No contacts found</h3>
            <p className="mt-1 text-sm text-gray-500">
              No contacts match "{searchQuery}"
            </p>
          </div>
        ) : (
          contacts.map((contact) => (
            <ContactRow 
              key={contact.id} 
              contact={contact} 
              onDelete={handleDelete}
              isDeleting={deletingId === contact.id}
              formatDate={formatDate}
            />
          ))
        )}
      </div>
    </div>
  );
}

function ContactRow({ 
  contact, 
  onDelete, 
  isDeleting, 
  formatDate 
}: { 
  contact: Contact; 
  onDelete: (contact: Contact) => void;
  isDeleting: boolean;
  formatDate: (date: string) => string;
}) {
  return (
    <div className="p-6 hover:bg-gray-50 transition-colors">
      <div className="flex items-center justify-between">
        <div className="flex-1 min-w-0">
          {/* Contact Name */}
          <div className="flex items-center gap-3">
            <div className="flex-1">
              <h3 className="text-lg font-semibold text-gray-900">
                {contact.firstName} {contact.lastName}
              </h3>
              
              {/* Company */}
              {contact.company && (
                <div className="flex items-center gap-1 mt-1">
                  <BuildingOfficeIcon className="w-4 h-4 text-gray-400" />
                  <p className="text-sm text-gray-600">{contact.company}</p>
                </div>
              )}
              
              {/* Meta info */}
              <div className="flex items-center gap-4 mt-2 text-sm text-gray-500">
                <span>Added {formatDate(contact.dateAdded)}</span>
                
                {contact.metAt && (
                  <>
                    <span>•</span>
                    <span>Met at {contact.metAt}</span>
                  </>
                )}
              </div>
            </div>
            
            {/* Follow-up indicator */}
            {contact.nextFollowUp && (
              <div className="flex items-center gap-1 text-orange-600">
                <BellIcon className="w-4 h-4" />
                <span className="text-xs font-medium">Follow-up</span>
              </div>
            )}
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2 ml-4">
          <button
            onClick={() => onDelete(contact)}
            disabled={isDeleting}
            className={`p-2 text-gray-400 hover:text-red-600 transition-colors ${
              isDeleting ? 'opacity-50 cursor-not-allowed' : ''
            }`}
            title="Delete contact"
          >
            <TrashIcon className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Contact details */}
      <div className="mt-3 flex flex-wrap gap-4 text-sm">
        {contact.email && (
          <a 
            href={`mailto:${contact.email}`}
            className="text-blue-600 hover:text-blue-800"
          >
            {contact.email}
          </a>
        )}
        
        {contact.phone && (
          <a 
            href={`tel:${contact.phone}`}
            className="text-blue-600 hover:text-blue-800"
          >
            {contact.phone}
          </a>
        )}
        
        {contact.quickTags && contact.quickTags.length > 0 && (
          <div className="flex gap-1">
            {contact.quickTags.slice(0, 3).map((tag, index) => (
              <span 
                key={index}
                className="px-2 py-1 bg-gray-100 text-gray-600 rounded-full text-xs"
              >
                {tag}
              </span>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="bg-white rounded-lg shadow p-12 text-center">
      <UserGroupIcon className="mx-auto h-16 w-16 text-gray-400" />
      <h2 className="mt-4 text-xl font-semibold text-gray-900">No Contacts Yet</h2>
      <p className="mt-2 text-gray-600 max-w-md mx-auto">
        Add your first networking contact in just 5 seconds. Click the "Add Contact" button above to get started.
      </p>
    </div>
  );
}