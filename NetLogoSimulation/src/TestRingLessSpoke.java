

public class TestRingLessSpoke extends BaseTest {
	
	public TestRingLessSpoke(){
		super();
		
		try {
			Network.run(new String[0], "Ring Network Less Spokes", "10", "0.3");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}
	
	@Override
	public void testNumberofTicks() {	
		try {
			assertEquals(157, Network.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	@Override
	public void testConvergenceValue() {
		try {
			assertEquals(28.86, Network.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
	
	@Override
	public void testInfluenceValue() {	
		try {
			assertEquals(0.32, Network.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
	}
}
