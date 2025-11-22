import '../models/customerModels/customer_model.dart';
import '../models/customerModels/customer_mock.dart';

class CustomerService {
  static final CustomerService _instance = CustomerService._internal();
  factory CustomerService() => _instance;

  CustomerService._internal();

  Customer _currentCustomer = mockCustomer.first;

  Customer getCustomer() => _currentCustomer;

  void updateCustomer(Customer customer) {
    _currentCustomer = customer;
  }

  void updateImage(String url) {
    _currentCustomer = Customer(
      id: _currentCustomer.id,
      name: _currentCustomer.name,
      email: _currentCustomer.email,
      phoneNumber: _currentCustomer.phoneNumber,
      imageUrl: url,
    );
  }
}
