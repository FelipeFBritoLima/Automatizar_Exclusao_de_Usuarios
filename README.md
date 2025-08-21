# Justificativa
Em instituições de ensino ou locais de trabalho, onde multiplos usuarios compartilham da mesma máquina, depois de um certo tempo começa a ocupar bastante espaço de armazenamento e novas conexões de usuarios serão mais lentas. Existe uma regra da GPO que desativa usuarios da máquina depois de um certo tempo de não ter sido logado, porém a partir do Windows 10, toda atualização da máquina atualiza nas pastas dos usuarios, configurando como se o usuario tivesse sido logado, então a regra da GPO não acaba funcionando ( Não foi testada em ambientes do Windows 11, mas como compartilham da mesma arquitetura da versão antesessor, acredito que deve persistir o mesmo problema).  

## Resolução
Como a regra da GPO não resolver o problema, foi desenvolvido três scripts do PowerShell para a realização desta tarefa, sendo o primeiro de setar a prioredade temporaria para execussão de scripts, segundo o de exclusão das pastas dos usuarios e o ultimo apagar o registros desses usuarios. 

## Etapas
- Primeiro deve-se criar uma GPO na pasta que se localiza os computadores que deve ocorrer a limpeza e editar ela e ir para os seguintes caminhos, **omputer Configuration - Polices - Windows Settings - Scripts(Startup/Shutdown) - Shutdown**  e adicionar o primeiro script **Setar Prioridade Temporaria.ps1** que é para definirir prioridade tamporaria para execusão de alguns recusrsos
- Depois deve se colocar o script **Apagar_usuario.ps1**, tendo um filtro dentro dele de quais usuarios você não quer que seja apagados, pois se apagar todos os usuarios , poderá ocorrer do sistema operacional corromper, então pode editar o scirpt
