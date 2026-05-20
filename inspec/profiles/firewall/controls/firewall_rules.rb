control 'p11-firewall-policy' do
  impact 1.0
  title 'El cortafuegos aplica una politica restrictiva'

  describe command('iptables -S FORWARD') do
    its('stdout') { should match(/-P FORWARD DROP/) }
    its('stdout') { should match(/--dport 80 -j ACCEPT/) }
    its('stdout') { should match(/--dport 22/) }
    its('stdout') { should match(/P11_SSH/) }
    its('stdout') { should match(/P11_DNS/) }
  end
end

control 'p11-firewall-http-mitigation' do
  impact 0.8
  title 'El cortafuegos bloquea patrones HTTP de path traversal'

  describe command('iptables-save') do
    its('stdout') { should match(/string.*\.\.\//) }
    its('stdout') { should match(/string.*%2e%2e/i) }
  end
end

control 'p11-suricata-rules' do
  impact 0.9
  title 'Suricata contiene reglas de deteccion del proyecto'

  describe file('/etc/suricata/rules/project11.rules') do
    it { should exist }
    its('content') { should match(/P11 SSH brute force pattern/) }
    its('content') { should match(/P11 DNS burst or suspicious replay/) }
    its('content') { should match(/P11 HTTP path traversal attempt/) }
  end
end

control 'p11-firewall-evidence' do
  impact 0.7
  title 'Los logs del cortafuegos contienen eventos de comportamiento no deseado'

  only_if('La emulacion debe haberse ejecutado al menos una vez') do
    file('/var/log/suricata/eve.json').exist?
  end

  describe command("jq -r 'select(.event_type==\"alert\") | .alert.signature' /var/log/suricata/eve.json | sort -u") do
    its('stdout') { should match(/P11/) }
  end
end

