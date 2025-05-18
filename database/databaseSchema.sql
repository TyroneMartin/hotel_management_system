-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'manager', 'supervisor', 'employee')),
  is_active BOOLEAN DEFAULT TRUE,
  phone_number VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

-- Room Types table
CREATE TABLE room_types (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  description TEXT,
  base_rate NUMERIC(10,2) NOT NULL,
  max_occupancy INT NOT NULL,
  amenities JSONB 
);

-- Rooms table
CREATE TABLE rooms (
  id SERIAL PRIMARY KEY,
  room_number VARCHAR(10) NOT NULL UNIQUE,
  floor VARCHAR(5) NOT NULL,
  room_type_id INT NOT NULL REFERENCES room_types(id),
  status VARCHAR(15) NOT NULL CHECK (status IN ('vacant', 'occupied', 'dirty', 'out_of_order', 'maintenance')),
  is_smoking BOOLEAN DEFAULT FALSE,
  is_accessible BOOLEAN DEFAULT FALSE,
  notes TEXT
);

-- Create index on status for quick availability searches
CREATE INDEX idx_rooms_status ON rooms(status);

-- Guests table (for guest information)
CREATE TABLE guests (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone_number VARCHAR(20),
  address TEXT,
  city VARCHAR(50),
  state VARCHAR(50),
  zip_code VARCHAR(20),
  country VARCHAR(50),
  id_type VARCHAR(20), 
  id_number VARCHAR(50),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index on email and last name 
CREATE INDEX idx_guests_email ON guests(email);
CREATE INDEX idx_guests_last_name ON guests(last_name);

-- Rates table 
CREATE TABLE rates (
  id SERIAL PRIMARY KEY,
  room_type_id INT NOT NULL REFERENCES room_types(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  rate_multiplier NUMERIC(5,2) DEFAULT 1.0,
  reason VARCHAR(50), 
  CONSTRAINT date_range_check CHECK (end_date >= start_date)
);

-- Reservations table 
CREATE TABLE reservations (
  id SERIAL PRIMARY KEY,
  reservation_number VARCHAR(20) NOT NULL UNIQUE,
  guest_id INT NOT NULL REFERENCES guests(id),
  created_by_user_id INT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  check_in_date DATE NOT NULL,
  check_out_date DATE NOT NULL,
  adults INT NOT NULL DEFAULT 1,
  children INT NOT NULL DEFAULT 0,
  special_requests TEXT,
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'no_show', 'checked_in', 'checked_out')),
  payment_status VARCHAR(20) NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'refunded')),
  source VARCHAR(50), 
  CONSTRAINT valid_stay_dates CHECK (check_out_date > check_in_date)
);

-- Create indexes for common queries
CREATE INDEX idx_reservations_dates ON reservations(check_in_date, check_out_date);
CREATE INDEX idx_reservations_status ON reservations(status);

-- Reservation Details table (for multiple rooms per reservation)
CREATE TABLE reservation_rooms (
  id SERIAL PRIMARY KEY,
  reservation_id INT NOT NULL REFERENCES reservations(id),
  room_id INT REFERENCES rooms(id), -- NULL if not yet assigned
  room_type_id INT NOT NULL REFERENCES room_types(id),
  rate_amount NUMERIC(10,2) NOT NULL,
  actual_check_in TIMESTAMP,
  actual_check_out TIMESTAMP,
  status VARCHAR(20) NOT NULL DEFAULT 'reserved' CHECK (status IN ('reserved', 'checked_in', 'checked_out', 'cancelled'))
);

-- Payments table
CREATE TABLE payments (
  id SERIAL PRIMARY KEY,
  reservation_id INT NOT NULL REFERENCES reservations(id),
  amount NUMERIC(10,2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  transaction_id VARCHAR(100),
  status VARCHAR(20) NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  notes TEXT
);

-- Messages table
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  reservation_id INT NOT NULL REFERENCES reservations(id),
  user_id INT REFERENCES users(id), -- NULL if guest message
  guest_id INT REFERENCES guests(id), -- NULL if staff message
  message_text TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Services table (for hotel amenities/services)
CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

-- Room service/additional charges
CREATE TABLE charges (
  id SERIAL PRIMARY KEY,
  reservation_room_id INT NOT NULL REFERENCES reservation_rooms(id),
  service_id INT REFERENCES services(id),
  description VARCHAR(255) NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  charge_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  charged_by_user_id INT REFERENCES users(id),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'waived', 'refunded'))
);

-- Housekeeping table
CREATE TABLE housekeeping (
  id SERIAL PRIMARY KEY,
  room_id INT NOT NULL REFERENCES rooms(id),
  assigned_to_user_id INT REFERENCES users(id),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'in_progress', 'completed', 'verified')),
  priority VARCHAR(10) NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high')),
  notes TEXT,
  scheduled_date DATE NOT NULL,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance requests
CREATE TABLE maintenance (
  id SERIAL PRIMARY KEY,
  room_id INT NOT NULL REFERENCES rooms(id),
  reported_by_user_id INT REFERENCES users(id),
  assigned_to_user_id INT REFERENCES users(id),
  issue_description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL CHECK (status IN ('reported', 'assigned', 'in_progress', 'completed', 'verified')),
  priority VARCHAR(10) NOT NULL DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'emergency')),
  reported_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP
);

-- Audit logs for tracking important changes
CREATE TABLE audit_logs (
  id SERIAL PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL,
  record_id INT NOT NULL,
  action VARCHAR(10) NOT NULL CHECK (action IN ('insert', 'update', 'delete')),
  user_id INT REFERENCES users(id),
  old_data JSONB,
  new_data JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables with updated_at
CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_guests_timestamp BEFORE UPDATE ON guests
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_reservations_timestamp BEFORE UPDATE ON reservations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();
