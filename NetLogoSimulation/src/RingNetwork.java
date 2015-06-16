import java.text.NumberFormat;

import org.nlogo.app.App;

public class RingNetwork {
	
	private static String nbOfAgents = "10";
	private static String epsilon = "0.3";
	private static String nbOfSpokes = "0";
	//private final float convergent_factor = 0.00001f;
	public static int nbOfTicks;
	public static float nodeCentral;
	public static float nodeSatellite;
	public static float convergenceValue;
	public static float influenceValue;
	
	RingNetwork(){
		
	}
	
	RingNetwork(int agents, float eps){
		nbOfAgents = Integer.toString(agents);
		epsilon = Float.toString(eps);
	}
	
	RingNetwork(int agents, float eps, int spokes){
		nbOfAgents = Integer.toString(agents);
		epsilon = Float.toString(eps);
		nbOfSpokes = Integer.toString(spokes);
	}
	
	public static void run(String[] args, final String agents, final String eps, final String spokes){
		App.main(args);
	    try {
	      java.awt.EventQueue.invokeAndWait(
	    new Runnable() {
	      public void run() {
	        try {
	          App.app().open(
	        "models/"
	        + "NetworkConsensus.nlogo");
	          nbOfAgents = agents;
	          epsilon = eps;
	          nbOfSpokes = spokes;
	        }
	        catch(java.io.IOException ex) {
	          ex.printStackTrace();
	        }}});
	      if (spokes == "0")
	    	  App.app().command("set network-type? \"Ring Network\"");
	      else {
	    	  App.app().command("set network-type? \"Ring Network Less Spokes\"");
	    	  App.app().command("set total-spokes " + nbOfSpokes);
	      }
	      App.app().command("set total-agents " + nbOfAgents);
	      App.app().command("set head's-value 100");
	      App.app().command("set other's-value 10");
	      App.app().command("set epsilon " + epsilon);
	      App.app().command("set is-vary-eps? false");
	      App.app().command("set show-self-value true");
	      App.app().command("set print-log-header true");
	      App.app().command("setup");
	      App.app().command("go");
	      /* Computer and print result */
	      NumberFormat nf = NumberFormat.getInstance();
	      nbOfTicks = nf.parse("" + App.app().report("ticks")).intValue() + 1;
	      convergenceValue = nf.parse("" + App.app().report("(precision ([self-val] of turtle 1) p)")).floatValue();
	      influenceValue = nf.parse("" + App.app().report("precision (((precision ([self-val] of turtle 1) p) / (head's-value - other's-value))) p")).floatValue();
	      System.out.println("Ticks: " + nbOfTicks);
	      System.out.println("Convergence value: " + convergenceValue);
	      System.out.println("Influence report: " + influenceValue);
	    }
	    catch(Exception ex) {
	      ex.printStackTrace();
	    }
	}
	
	public static void main(String[] args) {
		RingNetwork.run(args, "10", "0.3", "1");
	}
}
