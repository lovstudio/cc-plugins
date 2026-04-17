---
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
description: Initialize Supabase auth system connecting to LovStudio platform
version: "1.0.0"
author: "公众号：手工川"
---

# /init-auth - Initialize LovStudio Auth System

Initialize authentication for a React/Vite project, connecting to LovStudio's unified Supabase backend.

## LovStudio Supabase Config

```
VITE_SUPABASE_URL=https://mgfhqkixkjjwqwqrgvpg.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nZmhxa2l4a2pqd3F3cXJndnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNjg3ODYsImV4cCI6MjA1MTc0NDc4Nn0.KFMgbcZKiPqGPnNnrQjvIBVcKEKP8SPy-728FqJU2rI
```

## Process

### Step 1: Check Prerequisites

1. Verify project is React/Vite:
   - Check for `vite.config.ts` or `vite.config.js`
   - Check for `package.json` with react dependency
2. Check if auth already initialized:
   - Look for `src/integrations/supabase/client.ts`
   - Look for `src/hooks/useAuth.tsx`

If already initialized, ask user if they want to overwrite.

### Step 2: Install Dependencies

```bash
pnpm add @supabase/supabase-js jotai zod
```

### Step 3: Create Directory Structure

```
src/
├── integrations/
│   └── supabase/
│       ├── client.ts      # Supabase client
│       └── types.ts       # Database types
├── hooks/
│   └── useAuth.tsx        # Auth context & hook
├── store/
│   └── authAtoms.ts       # Jotai atoms (guestMode)
└── pages/
    └── Auth.tsx           # Auth page component
```

### Step 4: Create Files

#### 4.1 `src/integrations/supabase/client.ts`

```typescript
import { createClient } from '@supabase/supabase-js';
import type { Database } from './types';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_PUBLISHABLE_KEY = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY;

export const supabase = createClient<Database>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
  auth: {
    storage: localStorage,
    persistSession: true,
    autoRefreshToken: true,
  }
});
```

#### 4.2 `src/integrations/supabase/types.ts`

```typescript
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      profiles: {
        Row: {
          avatar_url: string | null
          created_at: string
          display_name: string | null
          email: string | null
          id: string
          updated_at: string
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          display_name?: string | null
          email?: string | null
          id: string
          updated_at?: string
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          display_name?: string | null
          email?: string | null
          id?: string
          updated_at?: string
        }
        Relationships: []
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
    }
    Enums: {
      app_role: "admin" | "user"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DefaultSchema = Omit<Database, "__InternalSupabase">[Extract<keyof Database, "public">]

export type Tables<
  T extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
> = (DefaultSchema["Tables"] & DefaultSchema["Views"])[T] extends { Row: infer R } ? R : never

export type TablesInsert<
  T extends keyof DefaultSchema["Tables"]
> = DefaultSchema["Tables"][T] extends { Insert: infer I } ? I : never

export type TablesUpdate<
  T extends keyof DefaultSchema["Tables"]
> = DefaultSchema["Tables"][T] extends { Update: infer U } ? U : never

export type Enums<T extends keyof DefaultSchema["Enums"]> = DefaultSchema["Enums"][T]
```

#### 4.3 `src/store/authAtoms.ts`

```typescript
import { atomWithStorage } from 'jotai/utils';

export const guestModeAtom = atomWithStorage('guestMode', false);
```

#### 4.4 `src/hooks/useAuth.tsx`

Reference implementation from lovstudio project. Key features:
- AuthProvider with React Context
- User, Session, Profile state management
- Admin role checking via user_roles table
- Guest mode support (isAdmin vs isActualAdmin)
- Methods: signUp, signIn, signInWithGoogle, signOut, resetPassword, updatePassword, resendVerificationEmail

#### 4.5 `src/pages/Auth.tsx`

Reference implementation with:
- Login/Register forms
- Google OAuth
- Email verification flow
- Password reset flow
- Form validation with zod
- Redirect handling via `?redirect=` param

### Step 5: Setup Environment

Check if `.env` or `.env.local` exists:
- If exists: append Supabase vars if not present
- If not exists: create `.env.local` with Supabase vars

```env
VITE_SUPABASE_URL=https://mgfhqkixkjjwqwqrgvpg.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1nZmhxa2l4a2pqd3F3cXJndnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNjg3ODYsImV4cCI6MjA1MTc0NDc4Nn0.KFMgbcZKiPqGPnNnrQjvIBVcKEKP8SPy-728FqJU2rI
```

### Step 6: Integration Instructions

Output instructions for user:

1. **Wrap App with AuthProvider**:
```tsx
// main.tsx or App.tsx
import { AuthProvider } from '@/hooks/useAuth';

<AuthProvider>
  <App />
</AuthProvider>
```

2. **Add Auth Route**:
```tsx
// In your router
import Auth from '@/pages/Auth';
<Route path="/auth" element={<Auth />} />
```

3. **Use Auth Hook**:
```tsx
import { useAuth } from '@/hooks/useAuth';

const { user, isAdmin, signOut } = useAuth();
```

4. **Protected Routes** (optional pattern):
```tsx
const ProtectedRoute = ({ children }) => {
  const { user, isLoading } = useAuth();
  if (isLoading) return <Loading />;
  if (!user) return <Navigate to="/auth" />;
  return children;
};
```

## Idempotency

- Check existing files before creating
- Check existing env vars before appending
- Ask user before overwriting

## Output

After completion, display:
- Files created/modified
- Next steps for integration
- Link to LovStudio docs (if available)
