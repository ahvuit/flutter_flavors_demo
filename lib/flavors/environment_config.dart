enum EnvironmentType { dev, uat, prod }

class EnvironmentConfig {
  final EnvironmentType env;
  final String apiUrl;

  EnvironmentConfig.dev()
      : env = EnvironmentType.dev,
        apiUrl = 'https://dummyjson-dev.com';

  EnvironmentConfig.uat()
      : env = EnvironmentType.uat,
        apiUrl = 'https://dummyjson-uat.com';

  EnvironmentConfig.prod()
      : env = EnvironmentType.prod,
        apiUrl = 'https://dummyjson-prod.com';
}
