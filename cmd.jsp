<%
ProcessBuilder pb = new ProcessBuilder("hostname");
Process p = pb.start();

java.io.BufferedReader r =
    new java.io.BufferedReader(new java.io.InputStreamReader(p.getInputStream()));

String line;
while ((line = r.readLine()) != null) {
    out.println(line);
}
%>
