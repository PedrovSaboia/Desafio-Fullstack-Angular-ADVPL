#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} STOTVST
gERENSIADOR DE TAREFAS 
@type function
@author p.saboia
@since 8/23/2025
/*/
User Function STOTVST()

	Local oBrowse 	:= Nil
	Private aRotina := MenuDef()

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("ZZG")

	//LEGENDA PARA DEMARCAR STATUS
	oBrowse:AddLegend( "ZZG_SITUAC == '1'", "BLUE" , "Pendente"  )
	oBrowse:AddLegend( "ZZG_SITUAC == '2'", "YELLOW" , "Em Andamento"  ) 
	oBrowse:AddLegend( "ZZG_SITUAC == '3'", "GREEN" , "Concluída"  )
	oBrowse:AddLegend( "ZZG_SITUAC == '4'", "RED"   , "Cancelada"  )

	oBrowse:SetDescription("Gerenciador de Tarefas")
	oBrowse:Activate()

Return


Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" 	 ACTION "VIEWDEF.STOTVST" 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 		 ACTION "VIEWDEF.STOTVST" 	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 		 ACTION "VIEWDEF.STOTVST" 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 		 ACTION "VIEWDEF.STOTVST" 	OPERATION 5 ACCESS 0

Return ( aRotina )

Static Function ModelDef()

	Local oModel     := Nil
	Local oStructZZG := FWFormStruct(1, 'ZZG' )
	Local oStructZZH := FWFormStruct(1, 'ZZH' )
	Local aZZHRel    := {}

	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('MODELZTASK', /*bPreValidacao*/, { |oModel| PosVal( oModel ) }, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('ZZGMASTER',/*cOwner*/,oStructZZG)
	oModel:AddGrid('ZZHDETAIL','ZZGMASTER',oStructZZH)

	//Fazendo o relacionamento entre o Pai e Filho
	aadd(aZZHRel, {'ZZH_FILIAL' , "FWxFilial('ZZG')"})
	aadd(aZZHRel, {'ZZH_CODTAR' , 'ZZG_CODIGO'})

	oModel:SetRelation('ZZHDETAIL', aZZHRel, ZZH->(IndexKey(1)))
	oModel:SetPrimaryKey({ 'ZZG_FILIAL' , 'ZZG_CODIGO' })

	// Validações
	oModel:SetVldActivate( { |oModel| PreVal( oModel ) } )

	//Setando as descrições
	oModel:SetDescription("Gerenciador de Tarefas")
	oModel:GetModel('ZZGMASTER'):SetDescription('Tarefa')
	oModel:GetModel('ZZHDETAIL'):SetDescription('Subtarefas')

Return ( oModel )


Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel( 'STOTVST' )
	Local oStructZZG := FWFormStruct(2, 'ZZG' )
	Local oStructZZH := FWFormStruct(2, 'ZZH' )

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField( 'VIEW_ZZG' , oStructZZG, 'ZZGMASTER' )
	oView:AddGrid(  'VIEW_ZZH' , oStructZZH, 'ZZHDETAIL' )

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC',40)
	oView:CreateHorizontalBox('GRID',60)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_ZZG','CABEC')
	oView:SetOwnerView('VIEW_ZZH','GRID')

	//Habilitando título
	oView:EnableTitleView('VIEW_ZZG','Tarefa')
	oView:EnableTitleView('VIEW_ZZH','Subtarefas')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})

Return oView

Static Function PreVal(oModel)

	Local lRet := .T.
	Local nOpc := oModel:GetOperation()

	// Validação para não permitir alteração se a tarefa estiver concluída ou cancelada
	If nOpc == 4 .AND. (ZZG->ZZG_SITUAC == '3' .OR. ZZG->ZZG_SITUAC == '4')
		lRet := .F.
		Help(,,'Alerta',,'Não é permitida a alteração de tarefas concluídas ou canceladas.',1,0)
	EndIf

Return lRet

Static Function PosVal(oModel)

	Local lRet       := .T.
	Local oModelZZG  := oModel:GetModel( 'ZZGMASTER' )
	Local oModelZZH  := oModel:GetModel( 'ZZHDETAIL' )
	Local nI         := 0
	Local nSubPend   := 0
    Local nSubConc   := 0

	// Validação da Data de Conclusão
	If !Empty(oModelZZG:GetValue("ZZG_DTCONC")) .AND. oModelZZG:GetValue("ZZG_DTCONC") < oModelZZG:GetValue("ZZG_DTINC")
        lRet := .F.
        Help(,, "Atenção", "A data de conclusão não pode ser menor que a data de inclusão.",,, 1)
        Return lRet
    EndIf

	// Validações de Status da Tarefa
	If oModelZZG:GetValue("ZZG_SITUAC") == "3" // Concluída
        For nI := 1 To oModelZZH:Length()
            oModelZZH:GoLine( nI )
            If oModelZZH:GetValue("ZZH_STATUS") == "1" // Pendente
                nSubPend++
            EndIf
        Next nI

        If nSubPend > 0
            lRet := .F.
            Help(,, "Atenção", "Não é possível concluir a tarefa pois existem subtarefas pendentes.",,, 1)
            Return lRet
        EndIf
    EndIf

    // Se todas as subtarefas estiverem concluídas, a tarefa principal também deve ser concluída
    For nI := 1 To oModelZZH:Length()
        oModelZZH:GoLine( nI )
        If oModelZZH:GetValue("ZZH_STATUS") == "3" // Concluída
            nSubConc++
        EndIf
    Next nI

    If oModelZZH:Length() > 0 .AND. nSubConc == oModelZZH:Length()
        oModelZZG:SetValue("ZZG_SITUAC", "3")
    EndIf

Return lRet


