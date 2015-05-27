import junit.framework.TestCase;


public class TestExample extends TestCase {
	
	//protected RadialNetwork radialNetwork;
	
	public TestExample(){
		super();
		
		try {
			RadialNetwork.run(new String[0], "12", "0.3");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	public void testNumberofTicksinRadial() {	
		try {
			assertEquals(2,RadialNetwork.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testConvergenceValueinRadial() {
		try {
			assertEquals(73.0,RadialNetwork.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	public void testInfluenceValueinRadial() {	
		try {
			assertEquals(0.81,RadialNetwork.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}

}
