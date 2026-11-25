/// Table, index, and column name constants for JatraNova's 20-table SQLite
/// schema. Data sources and migrations must reference these constants rather
/// than repeating raw string literals.
abstract final class DbTables {
  static const String users = 'users';
  static const String savedPassengers = 'saved_passengers';
  static const String busOperators = 'bus_operators';
  static const String stops = 'stops';
  static const String routes = 'routes';
  static const String trips = 'trips';
  static const String connectionRules = 'connection_rules';
  static const String tripSeats = 'trip_seats';
  static const String bookings = 'bookings';
  static const String bookingLegs = 'booking_legs';
  static const String bookingPassengers = 'booking_passengers';
  static const String demoPayments = 'demo_payments';
  static const String tickets = 'tickets';
  static const String ticketLegs = 'ticket_legs';
  static const String ticketQrTokens = 'ticket_qr_tokens';
  static const String ticketCancellations = 'ticket_cancellations';
  static const String ticketExchangeRequests = 'ticket_exchange_requests';
  static const String ticketExchangeHistory = 'ticket_exchange_history';
  static const String ticketRevenueSplits = 'ticket_revenue_splits';
  static const String notifications = 'notifications';

  static const List<String> allTables = <String>[
    users,
    savedPassengers,
    busOperators,
    stops,
    routes,
    trips,
    connectionRules,
    tripSeats,
    bookings,
    bookingLegs,
    bookingPassengers,
    demoPayments,
    tickets,
    ticketLegs,
    ticketQrTokens,
    ticketCancellations,
    ticketExchangeRequests,
    ticketExchangeHistory,
    ticketRevenueSplits,
    notifications,
  ];
}

abstract final class DbIndexes {
  static const String savedPassengersUser = 'idx_saved_passengers_user';
  static const String tripsSearch = 'idx_trips_search';
  static const String tripSeatsTripStatus = 'idx_trip_seats_trip_status';
  static const String bookingsUserCreated = 'idx_bookings_user_created';
  static const String demoPaymentsSuccessBooking =
      'uidx_demo_payments_success_booking';
  static const String ticketsNumber = 'idx_tickets_number';
  static const String ticketsOwnerIssued = 'idx_tickets_owner_issued';
  static const String activeTicketPerBookingPassenger =
      'uidx_active_ticket_per_booking_passenger';
  static const String ticketLegsTicket = 'idx_ticket_legs_ticket';
  static const String ticketLegsLegStatus = 'idx_ticket_legs_leg_status';
  static const String activeTicketLegPassenger =
      'uidx_active_ticket_leg_passenger';
  static const String activeQrPerTicket = 'uidx_active_qr_per_ticket';
  static const String ticketCancellationsBooking =
      'idx_ticket_cancellations_booking';
  static const String activeExchangePerTicket =
      'uidx_active_exchange_per_ticket';
  static const String notificationsUserReadCreated =
      'idx_notifications_user_read_created';
}

abstract final class UsersCols {
  static const String id = 'id';
  static const String fullName = 'full_name';
  static const String mobile = 'mobile';
  static const String email = 'email';
  static const String credentialHash = 'credential_hash';
  static const String avatarKey = 'avatar_key';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

abstract final class SavedPassengersCols {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String displayName = 'display_name';
  static const String fullName = 'full_name';
  static const String mobile = 'mobile';
  static const String email = 'email';
  static const String relationshipLabel = 'relationship_label';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

abstract final class BusOperatorsCols {
  static const String id = 'id';
  static const String nameEn = 'name_en';
  static const String nameBn = 'name_bn';
  static const String logoPath = 'logo_path';
  static const String isVerified = 'is_verified';
  static const String allowsExchange = 'allows_exchange';
  static const String exchangeCutoffMinutes = 'exchange_cutoff_minutes';
  static const String cancellationPolicyJson = 'cancellation_policy_json';
  static const String createdAt = 'created_at';
}

abstract final class StopsCols {
  static const String id = 'id';
  static const String cityCode = 'city_code';
  static const String nameEn = 'name_en';
  static const String nameBn = 'name_bn';
  static const String isPopular = 'is_popular';
  static const String isTransferHub = 'is_transfer_hub';
}

abstract final class RoutesCols {
  static const String id = 'id';
  static const String originStopId = 'origin_stop_id';
  static const String destinationStopId = 'destination_stop_id';
  static const String nameEn = 'name_en';
  static const String nameBn = 'name_bn';
  static const String isPopular = 'is_popular';
}

abstract final class TripsCols {
  static const String id = 'id';
  static const String operatorId = 'operator_id';
  static const String routeId = 'route_id';
  static const String originStopId = 'origin_stop_id';
  static const String destinationStopId = 'destination_stop_id';
  static const String busNameEn = 'bus_name_en';
  static const String busNameBn = 'bus_name_bn';
  static const String busType = 'bus_type';
  static const String departureAt = 'departure_at';
  static const String arrivalAt = 'arrival_at';
  static const String boardingPointEn = 'boarding_point_en';
  static const String boardingPointBn = 'boarding_point_bn';
  static const String dropOffPointEn = 'drop_off_point_en';
  static const String dropOffPointBn = 'drop_off_point_bn';
  static const String facilitiesJson = 'facilities_json';
  static const String fareMinor = 'fare_minor';
  static const String totalSeats = 'total_seats';
  static const String isPopular = 'is_popular';
  static const String isActive = 'is_active';
}

abstract final class ConnectionRulesCols {
  static const String id = 'id';
  static const String hubStopId = 'hub_stop_id';
  static const String operatorId = 'operator_id';
  static const String minBufferMinutes = 'min_buffer_minutes';
  static const String maxBufferMinutes = 'max_buffer_minutes';
  static const String transferInstructionsEn = 'transfer_instructions_en';
  static const String transferInstructionsBn = 'transfer_instructions_bn';
  static const String isActive = 'is_active';
}

abstract final class TripSeatsCols {
  static const String id = 'id';
  static const String tripId = 'trip_id';
  static const String seatNumber = 'seat_number';
  static const String seatClass = 'seat_class';
  static const String status = 'status';
  static const String holdUserId = 'hold_user_id';
  static const String holdSessionId = 'hold_session_id';
  static const String holdExpiry = 'hold_expiry';
  static const String bookingId = 'booking_id';
}

abstract final class BookingsCols {
  static const String id = 'id';
  static const String bookingNumber = 'booking_number';
  static const String userId = 'user_id';
  static const String bookingType = 'booking_type';
  static const String bookingStatus = 'booking_status';
  static const String paymentStatus = 'payment_status';
  static const String totalAmountMinor = 'total_amount_minor';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

abstract final class BookingLegsCols {
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String tripId = 'trip_id';
  static const String legOrder = 'leg_order';
  static const String transferPointEn = 'transfer_point_en';
  static const String transferPointBn = 'transfer_point_bn';
  static const String bufferMinutes = 'buffer_minutes';
  static const String demoTrackingStage = 'demo_tracking_stage';
  static const String demoDelayMinutes = 'demo_delay_minutes';
}

abstract final class BookingPassengersCols {
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String bookingLegId = 'booking_leg_id';
  static const String tripId = 'trip_id';
  static const String savedPassengerId = 'saved_passenger_id';
  static const String passengerGroupIndex = 'passenger_group_index';
  static const String passengerName = 'passenger_name';
  static const String passengerMobile = 'passenger_mobile';
  static const String passengerEmail = 'passenger_email';
  static const String seatId = 'seat_id';
  static const String seatNumberSnapshot = 'seat_number_snapshot';
}

abstract final class DemoPaymentsCols {
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String idempotencyKey = 'idempotency_key';
  static const String method = 'method';
  static const String status = 'status';
  static const String amountMinor = 'amount_minor';
  static const String createdAt = 'created_at';
  static const String completedAt = 'completed_at';
}

abstract final class TicketsCols {
  static const String id = 'id';
  static const String ticketNumber = 'ticket_number';
  static const String bookingId = 'booking_id';
  static const String passengerGroupIndex = 'passenger_group_index';
  static const String ownerUserId = 'owner_user_id';
  static const String holderName = 'holder_name';
  static const String holderMobile = 'holder_mobile';
  static const String holderEmail = 'holder_email';
  static const String originalTicketPriceMinor = 'original_ticket_price_minor';
  static const String status = 'status';
  static const String issuedAt = 'issued_at';
}

abstract final class TicketLegsCols {
  static const String id = 'id';
  static const String ticketId = 'ticket_id';
  static const String bookingId = 'booking_id';
  static const String bookingLegId = 'booking_leg_id';
  static const String legOrder = 'leg_order';
  static const String bookingPassengerId = 'booking_passenger_id';
  static const String passengerGroupIndex = 'passenger_group_index';
  static const String boardingStatus = 'boarding_status';
  static const String validatedAt = 'validated_at';
  static const String missedAt = 'missed_at';
  static const String validatedByDemoContext = 'validated_by_demo_context';
}

abstract final class TicketQrTokensCols {
  static const String id = 'id';
  static const String ticketId = 'ticket_id';
  static const String tokenHash = 'token_hash';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String revokedAt = 'revoked_at';
}

abstract final class TicketCancellationsCols {
  static const String id = 'id';
  static const String bookingId = 'booking_id';
  static const String ticketId = 'ticket_id';
  static const String cancelledByUserId = 'cancelled_by_user_id';
  static const String reason = 'reason';
  static const String refundPercentage = 'refund_percentage';
  static const String refundAmountMinor = 'refund_amount_minor';
  static const String refundStatus = 'refund_status';
  static const String cancelledAt = 'cancelled_at';
}

abstract final class TicketExchangeRequestsCols {
  static const String id = 'id';
  static const String ticketId = 'ticket_id';
  static const String senderUserId = 'sender_user_id';
  static const String receiverUserId = 'receiver_user_id';
  static const String receiverNameSnapshot = 'receiver_name_snapshot';
  static const String receiverMobileSnapshot = 'receiver_mobile_snapshot';
  static const String optionalMessage = 'optional_message';
  static const String status = 'status';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

abstract final class TicketExchangeHistoryCols {
  static const String id = 'id';
  static const String requestId = 'request_id';
  static const String oldTicketId = 'old_ticket_id';
  static const String newTicketId = 'new_ticket_id';
  static const String previousOwnerId = 'previous_owner_id';
  static const String newOwnerId = 'new_owner_id';
  static const String completedAt = 'completed_at';
}

abstract final class TicketRevenueSplitsCols {
  static const String id = 'id';
  static const String requestId = 'request_id';
  static const String originalTicketPriceMinor = 'original_ticket_price_minor';
  static const String operatorShareMinor = 'operator_share_minor';
  static const String exchangerShareMinor = 'exchanger_share_minor';
  static const String platformShareMinor = 'platform_share_minor';
  static const String createdAt = 'created_at';
}

abstract final class NotificationsCols {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String titleEn = 'title_en';
  static const String titleBn = 'title_bn';
  static const String messageEn = 'message_en';
  static const String messageBn = 'message_bn';
  static const String category = 'category';
  static const String isRead = 'is_read';
  static const String relatedRecordType = 'related_record_type';
  static const String relatedRecordId = 'related_record_id';
  static const String createdAt = 'created_at';
}
