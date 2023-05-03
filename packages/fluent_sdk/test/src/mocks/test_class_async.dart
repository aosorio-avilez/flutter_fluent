class TestClassAsync {
  static Future<TestClassAsync> build() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return TestClassAsync();
  }
}
