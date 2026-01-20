/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Настройка прокси для бэкенда
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://192.168.50.9:8080/api/:path*',
      },
      {
        source: '/v3/:path*',
        destination: 'http://192.168.50.9:8080/v3/:path*',
      },
    ];
  },
};

module.exports = nextConfig;
