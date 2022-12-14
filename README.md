# processaExperimentos_LiDAR_Interferometro
## Data experimento: 25/11/2022
## Local: Laboratório interferômetro
## Foram ralizados 4 experimentos, conforme descritos abaixo:

    1. Deslocamento do lidar a cada 200mm, a cada posição do LiDAR foi efetuada a medição 
            no interferômetro da posição da plataforma (com o LiDAR) que se deslocou ao longo do eixo principal
            da guia do interferômetro. O eixo "X" do LIDAR foi alinhado com o interferômetro, com o eixo "Z" 
            orientado na vertical, evitando qualquer rotação nos 3 eixos e translação nos eixos "Y" e "Z". 
            Para cada posição da plataforma foram coletadas N PCs, cuja bag no ROS tinha duração de 5 segundos. 
            Total do deslocamento foi de 3m.

    2. A montagem foi a mesma do experimento anterior, porém o LiDAR (plataforma) foi deslocado continuamente 
            ao longo dos 3m da guia do interferômetro. Neste experimento foram anotadas as posições inicial e final 
            medidas no interferômetro. O eixo "X" do LIDAR também foi alinhado com a guia do interferômetro, 
            evitando qualquer rotação e translação nos eixos "Y" e "Z". No início do experimento foi disparada 
            a aquisição no LiDAR, gerando uma bag de 30 segundos de PCs.

    3. Nesta experimento a montagem sofreu uma variação, o eixo "Z" do LiDAR foi alinhado com a guia do 
            interferômetro, ou seja, , com o eixo "X" orientado na vertical. Isto possibilitou efetuar uma varredura 
            sobre as superfícies a serem reconstruídas, que eram: tubo simulacro de riser e o padrão piramidal com esfers.
            O deslocamento total da plataforma correspondeu ao comprimento do tubo simulacro de riser, com passo de 50mm. 
            Para cada posição foi gerada uma bag com 5 segundos de duração. Para cada passo, posição, também foi 
            efetuada a medição do laser interferométrico. Esta montagem também evitou qualquer rotação e translação nos 
            eixos "X" e "X". 
    
    4. A montagem foi a mesma do experimento 03 (anterior), sendo que tal qual o experimento 02 o deslocamento  
            do LiDAR foi feito continuamente ao longo da guia. O deslocamento total correspondeu ao comprimento do 
            tubo simulacro de riser, ou seja, aprox. 1,8m. Neste experimento foram anotadas as posições inicial 
            e final medidas no interferômetro. No início do experimento foi disparada a aquisição no LiDAR, 
            gerando um bag de 30 segundos de PCs.