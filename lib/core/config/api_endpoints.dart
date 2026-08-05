class ApiEndpoints {
  static String get baseUrl => 'https://varakhata.jabedinternational.com/';
  static String get apiBaseUrl => 'https://varakhata.jabedinternational.com/api/';

  // ðŸ“¦ Auth
  String get registerUser => 'auth/register';
  String get loginUser => 'auth/login';
  String get forgotPasswordSendPin => 'forgot-password';
  String get forgotPasswordVerifyPin => 'verify-reset-pin';
  String get forgotPasswordSetNewPassword => 'reset-password';

  // ðŸ“¦ Home
  String get home => 'home';

  // ðŸ“¦ Properties & Units
  String get properties => 'properties';
  String get detailedProperties => 'detailed/properties';
  String propertyDetail(int id) => 'properties/$id';
  String get units => 'units';
  String unitDetail(int id) => 'units/$id';

  // ðŸ“¦ Tenants
  String get tenants => 'tenants';
  String tenantDetail(int id) => 'tenants/$id';
  String tenantEndLease(int id) => 'tenants/$id/end-lease';

  // ðŸ“¦ Bills
  String get bills => 'bills';
  String billDetail(int id) => 'bills/$id';

  // ðŸ“¦ Expenses
  String get expenses => 'expenses';
  String expenseDetail(int id) => 'expenses/$id';

  // ðŸ“¦ Finance â€” Rent Collections
  String get rentCollections => 'rent-collections';

  // ðŸ“¦ Finance â€” Transactions
  String get transactions => 'transactions';
  String transactionDetail(int id) => 'transactions/$id';

  // ðŸ“¦ Avatar
  String avatar(String path) => 'https://vcard.vaccinehomebd.com/storage/app/public/$path';

  // ðŸ“¦ Subscription
  String get subscriptionMe => 'subscription/me';

  // ðŸ“¦ Reports
  String get incomeExpenseReport => 'reports/income-expense';
}
