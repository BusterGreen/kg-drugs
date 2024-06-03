local Translations = {
    error = {
        has_no_drugs = "Você não está carregando nenhuma droga com você",
        not_enough_police = "Não há policiais suficientes de serviço (%{polices} requeridos)",
        no_drugs_left = "Não há mais drogas para vender",
        too_far_away = "Você se afastou muito",
        offer_declined = "Oferta recusada",
        no_player_nearby = "Nenhum jogador por perto",
        pending_delivery = "Você ainda precisa completar uma entrega, do que está esperando?!",
        item_unavailable = "Este item não está disponível, você recebeu um reembolso",
        order_not_right = "Isso não atende ao pedido",
        too_late = "Você está atrasado demais",
        dealer_already_exists = "Já existe um traficante com esse nome",
        dealer_not_exists = "Esse traficante não existe",
        no_dealers = "Nenhum traficante foi colocado",
        dealer_not_exists_command = "Traficante %{dealerName} não existe",
        in_vehicle = "Não é possível vender estando em um veículo"
    },
    success = {
        helped_player = "Você ajudou uma pessoa a se levantar",
        route_has_been_set = "A rota para o local de entrega foi definida no seu mapa",
        teleported_to_dealer = "Você foi teletransportado para %{dealerName}",
        offer_accepted = "Oferta aceita",
        order_delivered = "O pedido foi entregue",
        dealer_deleted = "Traficante %{dealerName} foi deletado"
    },
    info = {
        started_selling_drugs = "Você começou a vender drogas",
        stopped_selling_drugs = "Você parou de vender drogas",
        has_been_robbed = "Você foi roubado e perdeu %{bags} saco(s) de %{drugType}",
        suspicious_situation = "Situação suspeita",
        possible_drug_dealing = "Possível tráfico de drogas",
        drug_offer = "[E] %{bags}x %{drugLabel} por $%{randomPrice}? / [G] Recusar oferta",
        target_drug_offer = "Vender %{bags}x %{drugLabel} por $%{randomPrice}?",
        search_ped = "Procurar pessoa",
        pick_up_button = "[E] Pegar",
        knock_button = "[E] Bater",
        target_knock = 'Bater na porta',
        target_deliver = 'Entregar drogas',
        target_openshop = 'Abrir loja',
        target_request = 'Solicitar entrega',
        mystery_man_button = "[E] Comprar / [G] Ajudar o cara ($5000)",
        other_dealers_button = "[E] Comprar / [G] Iniciar uma missão",
        reviving_player = "Ajudando a pessoa a se levantar...",
        dealer_name = "Traficante %{dealerName}",
        sending_delivery_email = "Aqui estão todos os detalhes da entrega, eu vou manter contato por e-mail",
        mystery_man_knock_message = "Olá, meu filho, no que posso te ajudar?",
        treated_fred_bad = "Infelizmente, eu não negocio mais... Você deveria ter me tratado melhor",
        fred_knock_message = "E aí %{firstName}, no que posso te ajudar?",
        no_one_home = "Parece que não há ninguém em casa",
        delivery_info_email = "Aqui estão todas as informações sobre a entrega, <br>Itens: <br> %{itemAmount}x %{itemLabel}<br><br> Esteja pontual",
        deliver_items_button = "[E] Entregar %{itemAmount}x %{itemLabel}",
        delivering_products = "Entregando produtos...",
        drug_deal_alert = "911: Tráfico de Drogas",
        drug_deal = "Tráfico de Drogas",
        newdealer_command_desc = "Coloque um traficante (Apenas Admin)",
        newdealer_command_help1_name = "nome",
        newdealer_command_help1_help = "Nome do traficante",
        newdealer_command_help2_name = "min",
        newdealer_command_help2_help = "Tempo Mínimo",
        newdealer_command_help3_name = "max",
        newdealer_command_help3_help = "Tempo Máximo",
        deletedealer_command_desc = "Excluir um traficante (Apenas Admin)",
        deletedealer_command_help1_name = "nome",
        deletedealer_command_help1_help = "Nome do traficante",
        dealers_command_desc = "Ver todos os traficantes (Apenas Admin)",
        dealergoto_command_desc = "Teleportar para um traficante (Apenas Admin)",
        dealergoto_command_help1_name = "nome",
        dealergoto_command_help1_help = "Nome do traficante",
        list_dealers_title = "Lista de todos os traficantes: ",
        list_dealers_name_prefix = "Nome: ",
        selling_to_ped = "Vendendo drogas..."
    }
}

if GetConvar('kg_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
