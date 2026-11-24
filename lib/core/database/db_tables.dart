class DbTables {
  DbTables._();

  // Table names
  static const String users = 'users';
  static const String locations = 'locations';
  static const String operators = 'operators';
  static const String routes = 'routes';
  static const String buses = 'buses';
  static const String trips = 'trips';
  static const String seatInventory = 'seat_inventory';
  static const String bookings = 'bookings';
  static const String bookingLegs = 'booking_legs';
  static const String passengers = 'passengers';
  static const String tickets = 'tickets';
  static const String demoPayments = 'demo_payments';
  static const String handoverRequests = 'handover_requests';
  static const String handoverRecords = 'handover_records';
  static const String revenueSplits = 'revenue_splits';
  static const String connectionRules = 'connection_rules';
  static const String cancellationPolicies = 'cancellation_policies';
  static const String cancellationRules = 'cancellation_rules';
  static const String notifications = 'notifications';
  static const String savedPassengers = 'saved_passengers';
}

class UserColumns {
  UserColumns._();
  static const String id = 'id';
  static const String fullName = 'full_name';
  static const String mobile = 'mobile';
  static const String email = 'email';
  static const String passwordHash = 'password_hash';
  static const String avatarPath = 'avatar_path';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class LocationColumns {
  LocationColumns._();
  static const String id = 'id';
  static const String nameEn = 'name_en';
  static const String nameBn = 'name_bn';
  static const String code = 'code';
  static const String isActive = 'is_active';
}

class OperatorColumns {
  OperatorColumns._();
  static const String id = 'id';
  static const String nameEn = 'name_en';
  static const String nameBn = 'name_bn';
  static const String logoAsset = 'logo_asset';
  static const String isHandoverAllowed = 'is_handover_allowed';
  static const String handoverCommissionPct = 'handover_commission_pct';
}

class RouteColumns {
  RouteColumns._();
  static const String id = 'id';
  static const String originLocationId = 'origin_location_id';
  static const String destinationLocationId = 'destination_location_id';
  static const String distanceKm = 'distance_km';
  static const String estimatedDurationMinutes = 'estimated_duration_minutes';
}

class BusColumns {
  BusColumns._();
  static const String id = 'id';
  static const String operatorId = 'operator_id';
  static const String busName = 'bus_name';
  static const String busType = 'bus_type';
  static const String seatLayoutCode = 'seat_layout_code';
  static const String acType = 'ac_type';
  static const String facilitiesJson = 'facilities_json';
  static const String totalSeats = 'total_seats';
  static const String isActive = 'is_active';
}

class TripColumns {
  TripColumns._();
  static const String id = 'id';
  static const String busId = 'bus_id';
  static const String operatorId = 'operator_id';
  static const String routeId = 'route_id';
  static const String originLocationId = 'origin_location_id';
  static const String destinationLocationId = 'destination_location_id';
  static const String departureAt = 'departure_at';
  static const String arrivalAt = 'arrival_at';
  static const String boardingPoint = 'boarding_point';
  static const String dropOffPoint = 'drop_off_point';
  static const String fareAmount = 'fare_amount';
  static const String status = 'status';
}

class SeatInventoryColumns {
  SeatInventoryColumns._();
  static const String tripId = 'trip_id';
  static const String seatNumber = 'seat_number';
  static const String status = 'status';
  static const String holdUserId = 'hold_user_id';
  static const String holdExpiry = 'hold_expiry';
}

class BookingColumns {
  BookingColumns._();
  static const String id = 'id';
  static const String bookingCode = 'booking_code';
  static const String userId = 'user_id';
  static const String journeyType = 'journey_type';
  static const String bookingStatus = 'booking_status';
  static const String paymentStatus = 'payment_status';
  static const String passengerCount = 'passenger_count';
  static const String originLocationId = 'origin_location_id';
  static const String destinationLocationId = 'destination_location_id';
  static const String journeyDate = 'journey_date';
  static const String subtotalAmount = 'subtotal_amount';
  static const String serviceChargeAmount = 'service_charge_amount';
  static const String discountAmount = 'discount_amount';
  static const String totalAmount = 'total_amount';
  static const String createdAt = 'created_at';
}

class BookingLegColumns {
  BookingLegColumns._();
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String tripId = 'trip_id';
  static const String legOrder = 'leg_order';
  static const String transferPoint = 'transfer_point';
  static const String waitingMinutes = 'waiting_minutes';
  static const String legFareAmount = 'leg_fare_amount';
}

class PassengerColumns {
  PassengerColumns._();
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String fullName = 'full_name';
  static const String mobile = 'mobile';
  static const String email = 'email';
  static const String passengerOrder = 'passenger_order';
}

class TicketColumns {
  TicketColumns._();
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String bookingLegId = 'booking_leg_id';
  static const String tripId = 'trip_id';
  static const String passengerId = 'passenger_id';
  static const String seatNumber = 'seat_number';
  static const String ownerUserId = 'owner_user_id';
  static const String qrToken = 'qr_token';
  static const String originalTicketPrice = 'original_ticket_price';
  static const String ticketStatus = 'ticket_status';
  static const String issuedAt = 'issued_at';
  static const String invalidatedAt = 'invalidated_at';
}

class DemoPaymentColumns {
  DemoPaymentColumns._();
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String attemptNumber = 'attempt_number';
  static const String paymentMethod = 'payment_method';
  static const String status = 'status';
  static const String amount = 'amount';
  static const String isDemo = 'is_demo';
  static const String createdAt = 'created_at';
  static const String completedAt = 'completed_at';
}

class HandoverRequestColumns {
  HandoverRequestColumns._();
  static const String id = 'id';
  static const String ticketId = 'ticket_id';
  static const String senderId = 'sender_id';
  static const String receiverId = 'receiver_id';
  static const String receiverNameSnapshot = 'receiver_name_snapshot';
  static const String receiverMobileSnapshot = 'receiver_mobile_snapshot';
  static const String message = 'message';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class HandoverRecordColumns {
  HandoverRecordColumns._();
  static const String id = 'id';
  static const String handoverRequestId = 'handover_request_id';
  static const String previousOwnerId = 'previous_owner_id';
  static const String newOwnerId = 'new_owner_id';
  static const String oldTicketId = 'old_ticket_id';
  static const String newTicketId = 'new_ticket_id';
  static const String completedAt = 'completed_at';
}

class RevenueSplitColumns {
  RevenueSplitColumns._();
  static const String id = 'id';
  static const String handoverRecordId = 'handover_record_id';
  static const String originalTicketPrice = 'original_ticket_price';
  static const String operatorPercent = 'operator_percent';
  static const String handovererPercent = 'handoverer_percent';
  static const String platformPercent = 'platform_percent';
  static const String operatorShare = 'operator_share';
  static const String handovererShare = 'handoverer_share';
  static const String platformShare = 'platform_share';
  static const String createdAt = 'created_at';
}

class ConnectionRuleColumns {
  ConnectionRuleColumns._();
  static const String id = 'id';
  static const String operatorId = 'operator_id';
  static const String transferHubLocationId = 'transfer_hub_location_id';
  static const String minBufferMinutes = 'min_buffer_minutes';
  static const String maxWaitMinutes = 'max_wait_minutes';
  static const String isActive = 'is_active';
}

class CancellationPolicyColumns {
  CancellationPolicyColumns._();
  static const String id = 'id';
  static const String operatorId = 'operator_id';
  static const String policyName = 'policy_name';
}

class CancellationRuleColumns {
  CancellationRuleColumns._();
  static const String id = 'id';
  static const String policyId = 'policy_id';
  static const String minHoursBeforeDeparture = 'min_hours_before_departure';
  static const String refundPercent = 'refund_percent';
}

class NotificationColumns {
  NotificationColumns._();
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String title = 'title';
  static const String message = 'message';
  static const String category = 'category';
  static const String relatedType = 'related_type';
  static const String relatedId = 'related_id';
  static const String isRead = 'is_read';
  static const String createdAt = 'created_at';
}

class SavedPassengerColumns {
  SavedPassengerColumns._();
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String fullName = 'full_name';
  static const String mobile = 'mobile';
  static const String email = 'email';
  static const String gender = 'gender';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}
