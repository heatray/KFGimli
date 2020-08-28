class ROBufferedTCPLinkNoSteam extends ROBufferedTCPLink;

function Resolved(IpAddr Addr)
{
	// Set the address
	ServerIpAddr.Addr = Addr.Addr;
	ServerIpAddr.Port = 80;  // connect to http port

	// Handle failure.
	if (ServerIpAddr.Addr == 0)
		return;

	// Bind the local port.
	if (BindPort() == 0)
		return;

	OpenNoSteam(ServerIpAddr);
}
