export interface Contact {
  id: string;
  firstName: string;
  lastName: string;
  company?: string;
  jobTitle?: string;
  email?: string;
  phone?: string;
  metAt?: string;
  dateAdded: string;
  lastContact?: string;
  nextFollowUp?: string;
  notes?: string;
  interactionCount: number;
  quickTags: string[];
  conversationTopics: string[];
  reminders?: Reminder[];
}

export interface Reminder {
  id: string;
  contactId: string;
  reminderDate: string;
  message: string;
  completed: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface User {
  id: string;
  email: string;
  firstName?: string;
  lastName?: string;
}

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  message?: string;
}

export interface ContactsResponse {
  contacts: Contact[];
}

export interface AuthResponse {
  token: string;
  user: User;
}