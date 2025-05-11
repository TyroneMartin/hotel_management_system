-- Users table
users (
  id SERIAL PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  email TEXT UNIQUE,
  password TEXT,
  role TEXT CHECK (role IN ('manager', 'supervisor', 'employee'))
)

-- Rooms table
rooms (
  id SERIAL PRIMARY KEY,
  room_number TEXT,
  type TEXT,
  status TEXT CHECK (status IN ('vacant', 'occupied', 'dirty', 'out_of_order')),
  rate NUMERIC
)

-- Reservations table
reservations (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  room_id INT REFERENCES rooms(id),
  agent_id INT REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  first_name TEXT,
  last_name TEXT,
  email TEXT UNIQUE,
  phone_number TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  zip_code TEXT,
  country TEXT,
  total_guests INT,
  total_children INT,
  total_adults INT,
  total_rooms INT,
  total_cost NUMERIC,
  guest_count INT,
  check_in DATE,
  check_out DATE,
  status TEXT CHECK (status IN ('confirmed', 'cancelled', 'checked_in', 'checked_out'))
)

-- Messages table
messages (
  id SERIAL PRIMARY KEY,
  reservation_id INT REFERENCES reservations(id),
  sender_type TEXT CHECK (sender_type IN ('guest', 'agent')),
  message_text TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
