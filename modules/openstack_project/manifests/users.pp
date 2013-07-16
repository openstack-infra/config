# == Class: openstack_project::users
#
class openstack_project::users {
  @user::virtual::localuser { 'mordred':
    realname => 'Monty Taylor',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAyxfIpVCvZyM8BIy7r7WOSIG6Scxq4afean1Pc/bej5ZWHXCu1QnhGbI7rW3sWciEhi375ILejfODl2TkBpfdJe/DL205lLkTxAa+FUqcZ5Ymwe+jBgCH5XayzyhRPFFLn07IfA/BDAjGPqFLvq6dCEHVNJIui6oEW7OUf6a3376YF55r9bw/8Ct00F9N7zrISeSSeZXbNR+dEqcsBEKBqvZGcLtM4jzDzNXw1ITPPMGaoEIIszLpkkJcy8u/13GIrbAwNrB2wjl6Mzj+N9nTsB4rFtxRXp31ZbytCH5G9CL/mFard7yi8NLVEJPZJvAifNVhooxGN06uAiTFE8EsuQ== mtaylor@qualinost\n",
  }

  @user::virtual::localuser { 'corvus':
    realname => 'James E. Blair',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvKYcWK1T7e3PKSFiqb03EYktnoxVASpPoq2rJw2JvhsP0JfS+lKrPzpUQv7L4JCuQMsPNtZ8LnwVEft39k58Kh8XMebSfaqPYAZS5zCNvQUQIhP9myOevBZf4CDeG+gmssqRFcWEwIllfDuIzKBQGVbomR+Y5QuW0HczIbkoOYI6iyf2jB6xg+bmzR2HViofNrSa62CYmHS6dO04Z95J27w6jGWpEOTBjEQvnb9sdBc4EzaBVmxCpa2EilB1u0th7/DvuH0yP4T+X8G8UjW1gZCTOVw06fqlBCST4KjdWw1F/AuOCT7048klbf4H+mCTaEcPzzu3Fkv8ckMWtS/Z9Q== jeblair@operational-necessity\n",
  }

  @user::virtual::localuser { 'soren':
    realname => 'Soren Hansen',
    sshkeys  => '',
  }

  @user::virtual::localuser { 'smaffulli':
    realname => 'Stefano Maffulli',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD/zAvXaOUXCAT6/B4sCMu/38d/PyOIg/tYsYFAMgfDUzuZwkjZWNGrTpp/HFrOAZISER5KmOg48DKPvm91AeZOHfAXHCP6x9/FcogP9rmc48ym1B5XyIc78QVQjgN6JMSlEZsl0GWzFhQsPDjXundflY07TZfSC1IhpG9UgzamEVFcRjmNztnBuvq2uYVGpdI+ghmqFw9kfvSXJvUbj/F7Pco5XyJBx2e+gofe+X/UNee75xgoU/FyE2a6dSSc4uP4oUBvxDNU3gIsUKrSCmV8NuVQvMB8C9gXYR+JqtcvUSS9DdUAA8StP65woVsvuU+lqb+HVAe71JotDfOBd6f stefano@mattone-E6420\n",
  }

  @user::virtual::localuser { 'linuxjedi':
    realname => 'Andrew Hutchings',
    sshkeys  => '',
  }

  @user::virtual::localuser { 'oubiwann':
    realname => 'Duncan McGreggor',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAttca0Lahzo1rskWcCGwYh71ADmUsn/6RNBd7H7WVsX+QTacq90fpNghFNTen4I7tC1p0IemwHcCOb1noeXkjxl7W5r7l0OhiqMHp/u2ao0F3dINryuNEww2IHRhY6GwwGJ+slv+i4/FviUgqHZVzopUon/9VY0mu1wfu3vTRw0qXsvqr09Jiavt/8gJ0Fa5PsYkf7l0edFk0scTmGp3G4HY/ZvnbChfZMg6L/xcGPtK/GbLYg6PGtLVVnubXMtxD9GZYhwrY0i9Z2egcRI2W7IznM4OGFzYgA9HZqylPoWt4+ghzC5azUlbO2u6+8HigJVblAGHRWcznEf/ZDR3erw== oubiwann@rhosgobel\n",
  }

  @user::virtual::localuser { 'rockstar':
    realname => 'Paul Hummer',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd4dPOAooCImpPulKIH82LqahC2wtQAZS/bFjNRpEILaYQMPCEpSMpjQmhcjdq+OBtsHMbqkSR+ZEoDrkhsI3Y6NVyTlGeFfwCPNNt2VeuJlKqRHUxxecp0IPWGSNl+YI5rjO5hTIZEo9T+hngX2b4k7aPm/naGcBVETMdYDZt9yhX37w5irRFdMfNDdSa3VfrhqV3Jjge/sXA5Tv35s0O6R55Ww5KfZRTpAMesHWkH9ch6xaHgexLNyCtekZQKNRLR5FCk1SYdcV+BJNlmiyjH4Ed+Oy/dFlGWPNARGwNgEWbInROEqXdWvQf+ZAfuwo32umVmmPhFrBxDYrFR1Gp rockstar@spackrace.local\n",
  }

  @user::virtual::localuser { 'clarkb':
    realname => 'Clark Boylan',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDlH6SNieyGDWNl4b9TM+zUgk+XTXRtqxyYxNh1p5e00u/ZrZPVrc7buPhnTHzEde0ABX0vgnZI2rC5Hf9cYY0aRgLHDuikQ4CQHPucslgZ5linjtWx5AuURp+oaJRCj00UZubJsatUx5vz+D4MGRLYmL+MErftYdI4sBbolATfLVwjrmxsd6KF1BZ0+9eEv2Xrk+yXN1A5RGPKBiuE6viDMZxrOuy7IW8+TQZW1LrsbTCAD1b+J5Nx0z/Hn3Rz71zEibdwM9xgu5vROu3p9kdaxu+Ndg/SvCCWlzoLQSeIAmcfGUlWg9IjEc3sQexX9BmUAsKQtu3aZFgq2V7aqtDN boylancl@boylancl1\n",
  }

  @user::virtual::localuser { 'rlane':
    realname => 'Ryan Lane',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdtI7H+fsgSrjrdG8aGVcrN0GFW3XqLVsLG4n7JW4qH2W//hqgdL7A7cNVQNPoB9I1jAqvnO2Ct6wrVSh84QU89Uufw412M3qNSNeiGgv2c2KdxP2XBrnsLYAaJRbgOWJX7nty1jpO0xwF503ky2W3OMUsCXMAbYmYNSod6gAdzf5Xgo/3+eXRh7NbV1eKPrzwWoMOYh9T0Mvmokon/GXV5PiAA2bIaQvCy4BH/BzWiQwRM7KtiEt5lHahY172aEu+dcWxciuxHqkYqlKhbU+x1fwZJ+MpXSj5KBU+L0yf3iKySob7g6DZDST/Ylcm4MMjpOy8/9Cc6Xgpx77E/Pvd laner@Free-Public-Wifi.local\n",
  }

  @user::virtual::localuser { 'fungi':
    realname => 'Jeremy Stanley',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzKUUBTKJf6CGyz96JbmVSOSzf6LgXRmbyvSkSnD8EnBPFugWF5h/pPmLTVRfUzuR8p1CAR8ziNv0kJZexHvRbp0n06HWERWdK9AXr4utlJr9oc3b50Mmd5GHQp2QLd2sQrMx8G0pimPVoKPTVNvrlwrY1hjHldugX9IqD2QWIYsQEnqXHiVrCCiIcJFe/Gr/Qmz9nWTXN0fEQ7wsmrHAQtAs7YHJ/fNuS4JOtBTXS5trs9tcIBtPFyB2OeyOq85Wvg/IyHBv9Va2Zjccmu8+cedOsrz0YtOSb++uFAyeAe8BFEKD0EmHwhXVrG9UTWdNgQgL+YzdPPifjEbEh3HQoQ== fungi@yuggoth.org\n",
  }

  @user::virtual::localuser { 'ttx':
    realname => 'Thierry Carrez',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIF2INBeJdT3nT3+3yac+DGRQVN7wPv/GTb/OPDocQhfGMeQP7JwSURiv1nrXGbbjzuip7l7vRJs4u4NqXkUi0GFj1aLBpUm2Z1NFFDn4cuZ5KCYX6rjVrDYIpj4OlOyzt9YGONvvH/dB2GHw8kYbN50OalFWQCS0TVzj9SQbO47B/TPdtLnh116yEP5AXZZUGgl+q533/x8+nxAxJKA9iAk3mSswl67gXc4pRo84pjwpx+R/52ha6RfmLkoNAEOqtr5MGx5gyW+WXsoLJBl2bjcfzYoQI7gPWRIn+rtCnDFi762TS54zstXxR1ww+ppmqHk04l2oprNoI0wr00Fsl ttx@stardust\n",
  }

  @user::virtual::localuser { 'rbryant':
    realname => 'Russell Bryant',
    sshkeys  => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAx0vyiGg418eJlUffZRnusr8IAEgnF8Jpymu+//ANz68x+yszNpr5MSSRaRBgDny7XqFAGnuHfDf60EtLHf16PtBpoBo0Ftyjr/8ZhzEHxkLq7KOQ7TrP+GxGypLKUkCD9bZteakp8wqi+NTod7PtQh9SrnxDILcqHxP47UAPTSzzuKQXj6WNA9hoGCIKI/rivUo/4ZY5iUG2tfdJQf0J9dJw2TYQdmygjgEU9K7t+aWEOqIe21vbantZLWkrY7IxBbnNs2DOkmd+pRSprW7vh/p+ivgN4QPB2ZxqdPXeMY2eqpolQXS1wnLjhTsKkRpQP5/af2BcVLbHAlyBc94jKQ== russell@russellbryant.net\n",
  }
}
