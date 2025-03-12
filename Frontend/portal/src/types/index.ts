export type TransactionStatus = 'pending' | 'completed' | 'failed'

export interface Transaction {
  id: string
  amount: number
  currency: string
  status: TransactionStatus
  senderOrganization: string
  receiverOrganization: string
  timestamp: string
  fees: number
  exchangeRate: number
}

export interface Organization {
  id: string
  name: string
  country: string
  status: 'active' | 'inactive'
}

export interface KYCDocument {
  id: string
  userId: string
  type: 'passport' | 'id_card' | 'driving_license'
  status: 'pending' | 'approved' | 'rejected'
  submittedAt: string
  reviewedAt?: string
  reviewedBy?: string
}

export interface AuditLog {
  id: string
  action: string
  performedBy: string
  timestamp: string
  details: Record<string, any>
}