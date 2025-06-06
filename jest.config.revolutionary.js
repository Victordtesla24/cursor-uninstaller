export default {
    preset: 'ts-jest/presets/default-esm',
    extensionsToTreatAsEsm: ['.ts'],
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
            branches: 50,
            functions: 50,
            lines: 50,
            statements: 50
        }
    },
    setupFilesAfterEnv: ['<rootDir>/tests/revolutionary-setup.js'],
    testTimeout: 30000,
    verbose: true,
    transform: {
        '^.+\\.ts$': ['ts-jest', {
            useESM: true
        }]
    },
    globals: {
        REVOLUTIONARY_MODE: true,
        UNLIMITED_CAPABILITY: true
    }
};
