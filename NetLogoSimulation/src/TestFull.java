import junit.framework.TestCase;


public class TestFull extends TestCase {
	
	public TestFull(){
		super();
		
		try {
			FullNetwork.run(new String[0], "10", "0.1");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	public void testNumberofTicksinFull() {	
		try {
			assertEquals(26,FullNetwork.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testConvergenceValueinFull() {
		try {
			assertEquals(25,FullNetwork.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testInfluenceValueinFull() {	
		try {
			assertEquals(0.94,FullNetwork.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
}
