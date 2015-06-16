import junit.framework.TestCase;


public class TestRingLessSpoke extends TestCase {
	
	public TestRingLessSpoke(){
		super();
		
		try {
			RingNetwork.run(new String[0], "10", "0.3", "1");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}
	
	public void testNumberofTicksinRing() {	
		try {
			assertEquals(157,RingNetwork.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testConvergenceValueinRing() {
		try {
			assertEquals(28.86,RingNetwork.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testInfluenceValueinRing() {	
		try {
			assertEquals(0.32,RingNetwork.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
}
