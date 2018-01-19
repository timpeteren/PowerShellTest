
Utstedelse av SubCA sertifikat på offline Root CA

# Utstedelse av sertifikater

## Generelt

Det er god praksis å undersøke sertifikat request / forespørsel filer før man signerer dem og utsteder sertifikatet. Er det innlysende feilstavelser eller andre feilaktige / manglede opplysninger vil ikke sertifikatet kunne fungere som ønsket. Formålet med å gjøre en ekstra sjekk er ikke manglende tillitt til den som ønsker et signert sertifikat, men snarere en siste kvalitetssikring at sertifikatet kan brukes som tenkt.

Når en sertifikat forespørsel lagres til fil blir denne ofte hetende .req. Det kan være greit å vite at dette ikke er en forutsetning, og selv om filen lagres som .txt eller uten endelse i det hele tatt vil innholdet være likt. Man kan åpne filen med notepad eller annen tekst editor og se innholdet som begynner med -----BEGIN NEW CERTIFICATE REQUEST----- og slutter med -----END NEW CERTIFICATE REQUEST-----

En siste sjekk av sertifikat forespørselen vil kunne hjelpe å holde listen over utstedte sertifikater på "Issuing Certificate Authority" til et minimum. Det vil alltid være nødvendig å få utstedt sertifikater til test og lignende, men når disse ikke er i bruk lenger er det høyst anbefalt at slike sertifikater trekkes tilbake (revokeres). Årsaker til å trekke tilbake sertifikater vil oftest være at de har utspilt sin rolle og ikke lenger er i bruk, at levetiden er utløpt, eller at sertifikatet er kompromittert, noe som heldigvis er langt sjeldnere! Det anbefales på det sterkeste å holde orden i "Certificate Authority manageren" (certsrv.msc). 

## Certutil

For å undersøke innholdet i forespørselen bruker vi certutil.exe. Denne filen er innebygd i Windows operativsystemene og siden den ligger i system32 katalogen kan man kalle på certutil fra en hvilken som helst katalog. I dette eksempelet  antar vi at forespørselen kommer i form av en .req fil:
	
	Certutil -dump sertifikat.req
Man får en utskrift (dump) av alle egenskapene i den genererte forespørselen. Er forespørselen for et Web Server SSL sertifikat er det stort sett tre seksjoner av interesse som man bør se nøye gjennom: 

Subject:
Viktigst å se at Common name (CN=) feltet har riktig navn. 
Informasjon om den / de som ønsker å få utstedt sertifikatet bør også være fylt i, eksempelvis Organization(O=), Email address (E=),  Location (L=), Country (C=) med mer. Når man kjøper kommersielle sertifikater må disse feltene være utfylt for at organisasjonen skal kunne bli validert og dermed få lov å kjøpe gyldig signering fra utstederen.

Certificate Extensions:
Utvidelsen 1.3.6.1.4.1.311.20.2, Certificate Template Name, angir hvilken sertifikatmal forespørselen er tiltenkt. Står det  et navn her som ikke stemmer overens med ett av de publiserte sertifikatene må forespørselen lages på nytt da forsøk på signering av denne forespørselen vil feile med beskjed om at sertifikatmalen ikke er tilgjengelig, ikke overraskende.

Finn utvidelsen med identifikator 2.5.29.17, Subject Alternative Name, det vil si delen av sertifikatet hvor alternative eller ekstra navn legges inn. SAN feltet fylles alltid med den samme verdien som er lagt inn i Common name derfor er den mest brukte DNS navn (DNS Name=) fordi dette er på samme formatet som Common name, men ved noen tilfeller ser man også Other Name: User principal name (principal name=).
Grunnen til at SAN feltet inkluderer samme verdi  som i Common name feltet er at når en server eller klient skal validere sertifikatet varierer det om de bruker Subject: Common name feltet eller Subject Alternative Name: DNS name for å finne navn på sertifikatet og sammenligne det med adressen som de har kontaktet og fått presentert sertifikatet.

## Utstedelse av sertifikater på kommandolinjen!

Utstedelsesprosessen som her beskrives kan utføres på enhver server uten ekstra tilpasning. På en klient maskin må  Certificate Authority modulen fra Remote Server Administration Tools (RSAT) være installert for at det skal virke.

For at utstedelsesprosedyren skal kunne lykkes er det i tillegg et par andre forutsetninger som må oppfylles:
	 
• Det må være åpent i brannmur mellom klient eller server hvor man utfører prosdyren fra. Det er snakk om tcp/135 for å etablere kontakt med Certificate Authority og for utveksling av sertifikat benyttes tilfeldige porter fra tcp/49152 til tcp/65535, ofte omtalte som "high ports". Kjører man disse kommandoene fra selve CA serveren trenger man, naturlig nok, ikke ta høyde for dette.
 
• Bruker som starter kommandolinjen eller powershell prompten må tilstrekkelige rettigheter, definert på sertifikatmalen, for å få lov å signere sertifikatet mot denne malen. Dette medfører at prosedyren må utføres på en maskin som er medlem av samme domenet som sertifikatserveren for at dette skal fungere.

Vi forutsetter at maskinen dette kjøres fra har en mappe som heter Temp på C: stasjonen. I eksempelet heter Certificate Authority FERDE Issuing CA 01 og servernavnet er FERDE-CA, erstatt disse navnene med det reelle navnet på Issuing CA (evt se Certificate Authority Manager, certsrv.msc) og navnet på selve serveren, gjerne med FQDN (fully qualified domain name). Endre også navnet på sertifikatmalen som følger etter CertificateTemplate: til ønsket navn. Bruk sertifikatnavn, altså navn UTEN mellomrom, ikke sertifikatmalens visningsnavn. Merk spesielt at det er en blanding av Certreq og Certutil som brukes.

1. Cd C:\Temp

(Denne kommandoen vil generere en ID for forespørselen. Vi sier at dette blir tallet 141.)
2. Certreq –submit –config "FERDE-CA\Ferde Issuing CA 01" –attrib CertificateTemplate:FerdeWebServer C:\temp\sertifikat.req
     
(Benytt "ID" fra punktet over generert av Certreq -submit, 141)
3. Certutil –resubmit –config "FERDE-CA\Ferde Issuing CA 01” 141
     
(Bruk samme ID som de to foregående punktene, 141)
4. Certreq –retrieve –config "FERDE-CA\Ferde Issuing CA 01" 141 C:\Temp\sertifikat.cer
