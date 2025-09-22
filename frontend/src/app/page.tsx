'use client';

import { useState, useEffect } from 'react';
import ContactList from '@/components/ContactList';
import AddContactModal from '@/components/AddContactModal';
import { Contact } from '@/types';
import { apiService } from '@/lib/api';
import { PlusIcon } from '@heroicons/react/24/outline';

export default function Home() {
  const [contacts, setContacts] = useState<Contact[]>([]);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadContacts();
  }, []);

  const loadContacts = async (search?: string) => {
    try {
      setLoading(true);
      const contactsData = await apiService.getContacts(search);
      setContacts(contactsData);
      setError(null);
    } catch (err) {
      setError('Failed to load contacts. Please check if the backend is running.');
      console.error('Error loading contacts:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (query: string) => {
    setSearchQuery(query);
    await loadContacts(query);
  };

  const handleContactAdded = async (contact: Contact) => {
    await loadContacts(searchQuery); // Refresh the list
    setIsAddModalOpen(false);
  };

  const handleContactDeleted = async () => {
    await loadContacts(searchQuery); // Refresh the list
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading contacts...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center max-w-md mx-auto">
          <div className="text-red-500 text-6xl mb-4">⚠️</div>
          <h2 className="text-2xl font-bold text-gray-800 mb-4">Connection Error</h2>
          <p className="text-gray-600 mb-6">{error}</p>
          <button 
            onClick={() => loadContacts()}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Retry
          </button>
          <div className="mt-6 p-4 bg-yellow-50 border border-yellow-200 rounded-lg text-left">
            <p className="text-sm text-yellow-800">
              <strong>Quick Setup:</strong> Make sure your backend is running:
            </p>
            <code className="block mt-2 text-xs bg-gray-100 p-2 rounded">
              cd backend && npm run dev
            </code>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">NetworkCRM</h1>
              <p className="text-sm text-gray-500">Your networking contacts, simplified</p>
            </div>
            <button
              onClick={() => setIsAddModalOpen(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2"
            >
              <PlusIcon className="w-5 h-5" />
              Add Contact
            </button>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <ContactList 
          contacts={contacts}
          onSearch={handleSearch}
          onContactDeleted={handleContactDeleted}
          searchQuery={searchQuery}
        />
      </div>

      {/* Add Contact Modal */}
      <AddContactModal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        onContactAdded={handleContactAdded}
      />
    </div>
  );
}
  );
}
