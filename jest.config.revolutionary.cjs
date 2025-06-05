module.exports = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    roots: ['<rootDir>/tests'],
    testMatch: [
        '**/tests/**/*.test.(ts|js)',
        '**/tests/**/revolutionary-*.js'
    ],
    collectCoverageFrom: [
        'lib/**/*.{ts,js}',
        'modules/**/*.{ts,js}',
        '!**/*.d.ts',
        '!**/node_modules/**'
    ],
    coverageDirectory: 'coverage/revolutionary',
    coverageReporters: ['text', 'lcov', 'html'],
    coverageThreshold: {
        global: {
            branches: 99,
            functions: 99,
            lines: 99,
            statements: 99
        }
    },
    setupFilesAfterEnv: ['<rootDir>/tests/revolutionary-setup.js'],
    testTimeout: 30000,
    verbose: true,
    globals: {
        'ts-jest': {
            useESM: true
        },
        REVOLUTIONARY_MODE: true,
        UNLIMITED_CAPABILITY: true
    }
};
