import junit.framework.TestCase;


public abstract class BaseTest extends TestCase {
	
	public BaseTest(){}
	
	public abstract void testNumberofTicks();
	
	public abstract void testConvergenceValue();
	
	public abstract void testInfluenceValue();
}
