control 'p11-ssh-hardening' do
  impact 1.0
  title 'SSH esta endurecido'

  describe sshd_config do
    its('PermitRootLogin') { should cmp 'no' }
    its('PasswordAuthentication') { should cmp 'no' }
    its('MaxAuthTries') { should cmp 3 }
  end
end

control 'p11-nginx-hardening' do
  impact 0.8
  title 'Nginx reduce informacion expuesta'

  describe file('/etc/nginx/nginx.conf') do
    its('content') { should match(/server_tokens off;/) }
    its('content') { should match(/X-Content-Type-Options nosniff/) }
    its('content') { should match(/X-Frame-Options DENY/) }
  end
end

control 'p11-services' do
  impact 0.7
  title 'El servidor protegido ofrece solo servicios previstos para la practica'

  describe command('ss -lntu') do
    its('stdout') { should match(/:22\s/) }
    its('stdout') { should match(/:53\s/) }
    its('stdout') { should match(/:80\s/) }
  end
end
