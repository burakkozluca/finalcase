# AKBANK COBOL FİNAL PROJESİ

Bu proje, bir VSAM veri tabanındaki hesap kayıtlarını input dosyasına göre okuyan, güncelleyen, silen ve yeni kayıt ekleyen bir COBOL programıdır. Programın amacı, bir veritabanı dosyasıyla etkileşim kurarak verileri işlemektir.

## Dosya Yapısı

Programın çalışması için aşağıdaki dosya yapıları kullanılmaktadır:

 - ACCT-REC: VSAM veri tabanı dosyası. Her kayıt, hesap bilgilerini içeren bir kayıttan oluşur.
 - OUT-FILES: QSAM output dosyası. Yaptığımız işlemlerin loglarını tuttuğumuz dosyadır.
 - INP-FILES: QSAM input dosyası. Bu dosyada islem tipi ve id degerleri tutulur.

## Program Akışı (PBEGFNL)

1. H100-OPEN-FILES: INPUT ve OUTPUT dosyalarını açar. Dosyalar açılmazsa program sonlandırılır.
2. H200-PROCESS: giriş dosyasındaki kayıtları işler.
    - Kayıtlardaki INP-ISLEM-TIPI değerine göre ilgili işlemi gerçekleştirir.
    - WS-PBEGIDX alt programı çağrılarak işlem yapılır ve sonuçlar OUT-DATA alanına atanır.
    - OUT-DATA çıkış dosyasına yazılır.
    - Bir sonraki kayıt okunur.
3. İşlem tamamlanana kadar 2. adıma geri dönülür.
4. Program sonlandığında, H999-PROGRAM-EXIT alt programı çağrılarak dosyalar kapatılır ve program durdurulur.

## Program Akışı (PBEGIDX)
  
1. H100-OPEN-FILES: Veri tabanı dosyasını açar. Dosya açılamazsa program sonlandırılır.
2. H200-PROCESS: Verilen işlem türüne göre ilgili işlemin gerçekleştirilmesi için ilgili adıma yönlendirir.
3. H300-EVALUATE: İşlem türüne bağlı olarak ilgili adımın çalıştırılması için yönlendirir.
4. İşlem türüne bağlı olarak ilgili adımlar gerçekleştirilir. Bu adımlar şunlardır:
   - H400-READ-FILES: VSAM veri tabanından kayıtları okur.
   - H500-UPDATE: VSAM veri tabanındaki kayıtları günceller.
   - H600-DELETE: VSAM veri tabanından kayıtları siler.
   - H700-WRITE: Yeni bir kayıt ekler.
5. İşlem tamamlandıktan sonra program kapanır (H999-PROGRAM-EXIT). 
