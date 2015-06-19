

public class TestFull extends BaseTest {
	
	public TestFull(){
		super();
		try {
			Network.run(new String[0], "Full Network", "10", "0.3");
		} catch(Exception e) {
			System.err.println(e.getMessage());
		}
	}

	@Override
	public void testNumberofTicks() {
		try {
			assertEquals(24,Network.nbOfTicks);
		} catch(Exception e) {
			fail(e.getMessage());
		}
		
	}

	@Override
	public void testConvergenceValue() {
		try {
			assertEquals(46.63,Network.convergenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
		
	}

	@Override
	public void testInfluenceValue() {
		try {
			assertEquals(0.52,Network.influenceValue, 0.0001);
		} catch(Exception e) {
			fail(e.getMessage());
		}
		
	}
	
}
