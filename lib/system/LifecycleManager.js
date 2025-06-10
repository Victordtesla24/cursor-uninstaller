/**
 * Provides a standard interface for components that have a defined lifecycle
 * with setup and teardown operations. Subclasses are expected to implement
 * the initialize and shutdown methods.
 *
 * @interface
 */
class LifecycleManager {
  /**
   * Initializes the component. This method should be implemented by subclasses
   * to handle any setup logic, such as connecting to databases or initializing resources.
   * This method can be synchronous or return a Promise for asynchronous operations.
   */
  initialize() {
    throw new Error('LifecycleManager.initialize() must be implemented by subclass.');
  }

  /**
   * Shuts down the component. This method should be implemented by subclasses
   * to handle any cleanup logic, such as closing connections or releasing resources.
   * This method can be synchronous or return a Promise for asynchronous operations.
   */
  shutdown() {
    throw new Error('LifecycleManager.shutdown() must be implemented by subclass.');
  }
}

export default LifecycleManager; 