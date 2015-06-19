

public class TestRadial extends BaseTest {
	
	public TestRadial(){
		super();
		
		try {
			Network.run(new String[0], "Radial Network", "12", "0.3");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	@Override
	public void testNumberofTicks() {	
		try {
			assertEquals(2, Network.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	@Override
	public void testConvergenceValue() {
		try {
			assertEquals(73.0, Network.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	@Override
	public void testInfluenceValue() {	
		try {
			assertEquals(0.81, Network.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
}
