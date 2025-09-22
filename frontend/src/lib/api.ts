import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import { Contact, ContactsResponse, AuthResponse, User } from '@/types';

class ApiService {
  private api: AxiosInstance;
  
  constructor() {
    this.api = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api',
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Add token to requests if available
    this.api.interceptors.request.use((config) => {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Handle token expiration
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem('token');
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  // Auth methods
  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await this.api.post('/auth/login', { email, password });
    return response.data;
  }

  async register(email: string, password: string, firstName?: string, lastName?: string): Promise<AuthResponse> {
    const response = await this.api.post('/auth/register', { email, password, firstName, lastName });
    return response.data;
  }

  // Contact methods
  async getContacts(search?: string): Promise<Contact[]> {
    const params = search ? { search } : {};
    const response = await this.api.get('/contacts', { params });
    return response.data.contacts;
  }

  async getContact(id: string): Promise<Contact> {
    const response = await this.api.get(`/contacts/${id}`);
    return response.data.contact;
  }

  async createContact(contact: Omit<Contact, 'id' | 'dateAdded' | 'interactionCount'>): Promise<Contact> {
    const response = await this.api.post('/contacts', contact);
    return response.data.contact;
  }

  async updateContact(id: string, contact: Partial<Contact>): Promise<Contact> {
    const response = await this.api.put(`/contacts/${id}`, contact);
    return response.data.contact;
  }

  async deleteContact(id: string): Promise<void> {
    await this.api.delete(`/contacts/${id}`);
  }

  // Reminder methods
  async createReminder(contactId: string, reminderDate: string, message: string) {
    const response = await this.api.post('/reminders', { contactId, reminderDate, message });
    return response.data.reminder;
  }

  async getUpcomingReminders() {
    const response = await this.api.get('/reminders/upcoming');
    return response.data.reminders;
  }

  async completeReminder(id: string) {
    const response = await this.api.patch(`/reminders/${id}/complete`);
    return response.data.reminder;
  }
}

export const apiService = new ApiService();
export default apiService;