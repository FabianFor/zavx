// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get dashboard => 'Painel';

  @override
  String get products => 'Produtos';

  @override
  String get orders => 'Pedidos';

  @override
  String get invoices => 'Recibos';

  @override
  String get settings => 'Configurações';

  @override
  String get profile => 'Perfil';

  @override
  String get add => 'Adicionar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get name => 'Nome';

  @override
  String get description => 'Descrição';

  @override
  String get price => 'Preço';

  @override
  String get stock => 'Estoque';

  @override
  String get category => 'Categoria';

  @override
  String get food => 'Comida';

  @override
  String get drinks => 'Bebidas';

  @override
  String get desserts => 'Sobremesas';

  @override
  String get others => 'Outros';

  @override
  String get total => 'Total';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get cannotUndo => 'Esta ação não pode ser desfeita';

  @override
  String get noProducts => 'Sem produtos';

  @override
  String get noOrders => 'Sem pedidos';

  @override
  String get noInvoices => 'Sem recibos';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get currency => 'Moeda';

  @override
  String get selectCurrency => 'Selecionar moeda';

  @override
  String get businessProfile => 'Perfil do Negócio';

  @override
  String get businessName => 'Nome do Negócio';

  @override
  String get address => 'Endereço';

  @override
  String get phone => 'Telefone';

  @override
  String get email => 'E-mail';

  @override
  String get share => 'Compartilhar';

  @override
  String get download => 'Baixar';

  @override
  String get error => 'Erro';

  @override
  String get addImage => 'Adicionar imagem';

  @override
  String get changeImage => 'Alterar imagem';

  @override
  String get businessManagement => 'Gestão do Negócio';

  @override
  String get productsRegistered => 'Produtos Registrados';

  @override
  String get ordersPlaced => 'Pedidos Realizados';

  @override
  String get totalRevenue => 'Receita Total';

  @override
  String get createOrder => 'Criar Pedido';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get theme => 'Tema';

  @override
  String get searchProducts => 'Buscar produtos...';

  @override
  String get searchByCustomer => 'Buscar por cliente ou número...';

  @override
  String get customerName => 'Nome do Cliente';

  @override
  String get customerNameRequired => 'Nome do Cliente *';

  @override
  String get phoneOptional => 'Telefone (opcional)';

  @override
  String get nameRequired => 'O nome é obrigatório';

  @override
  String get addProduct => 'Adicionar Produto';

  @override
  String get editProduct => 'Editar Produto';

  @override
  String get minCharacters => 'Mínimo 2 caracteres';

  @override
  String get priceRequired => 'O preço é obrigatório';

  @override
  String get invalidPrice => 'Preço inválido';

  @override
  String get stockRequired => 'O estoque é obrigatório';

  @override
  String get invalidStock => 'Estoque inválido';

  @override
  String get addToOrder => 'Adicione pelo menos um produto ao pedido';

  @override
  String get insufficientStock => 'Estoque insuficiente para';

  @override
  String totalItems(int count) {
    return 'Total ($count itens):';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get orderCreatedSuccess => 'Pedido e recibo criados com sucesso';

  @override
  String get orderCreatedError => 'Erro ao criar pedido';

  @override
  String get noProductsAvailable => 'Nenhum produto disponível';

  @override
  String get noProductsFound => 'Nenhum produto encontrado';

  @override
  String get productAddedSuccess => 'Produto adicionado com sucesso';

  @override
  String get productUpdatedSuccess => 'Produto atualizado com sucesso';

  @override
  String get imageSelectedSuccess => 'Imagem selecionada com sucesso';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get permissionsDenied => 'Permissões negadas';

  @override
  String get close => 'Fechar';

  @override
  String get cart => 'Carrinho';

  @override
  String get viewCart => 'Ver Carrinho';

  @override
  String get quickAccess => 'Acesso Rápido';

  @override
  String get lowStockProducts => 'Produtos com estoque baixo';

  @override
  String get tapToChangeLogo => 'Toque para alterar o logo';

  @override
  String get businessNameRequired => 'O nome do negócio é obrigatório';

  @override
  String get invalidEmail => 'Digite um e-mail válido';

  @override
  String get profileUpdated => 'Perfil atualizado com sucesso';

  @override
  String get logoSelected => 'Logo selecionado com sucesso';

  @override
  String get needPermissions =>
      'Você precisa conceder permissões para escolher uma imagem';

  @override
  String get imageSelectionError => 'Erro ao selecionar imagem';

  @override
  String get darkModeSubtitle => 'Ativar tema escuro';

  @override
  String get businessProfileSubtitle => 'Edite as informações do seu negócio';

  @override
  String get version => 'Versão';

  @override
  String get filterByDate => 'Filtrar por data';

  @override
  String results(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noInvoicesFound => 'Nenhum recibo encontrado';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String productsCount(int count) {
    return '$count produto(s)';
  }

  @override
  String get deleteInvoice => 'Excluir recibo';

  @override
  String deleteInvoiceConfirm(int number) {
    return 'Tem certeza de que deseja excluir o Recibo #$number?\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get invoiceDeleted => 'Recibo excluído';

  @override
  String get needPermissionsToShare =>
      'Permissões necessárias para compartilhar';

  @override
  String get needPermissionsToDownload => 'Permissões necessárias para baixar';

  @override
  String get savedToGallery => 'Salvo na galeria';

  @override
  String get customerData => 'Dados do Cliente';

  @override
  String get nameField => 'Nome *';

  @override
  String get nameRequiredField => 'Nome obrigatório';

  @override
  String get phoneField => 'Telefone (opcional)';

  @override
  String get confirm => 'Confirmar';

  @override
  String get units => 'unidades';

  @override
  String get deleteProduct => 'Excluir produto';

  @override
  String get deleteProductConfirm =>
      'Tem certeza de que deseja excluir este produto?';

  @override
  String get productDeleted => 'Produto excluído com sucesso';

  @override
  String get permissionsNeeded => 'Permissões necessárias';

  @override
  String get permissionsMessage =>
      'Este aplicativo precisa de acesso às suas fotos para adicionar imagens aos produtos.\n\nVá para:\nConfigurações → Aplicativos → Proïon → Permissões → Fotos e mídia';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get needPermissionToSelectImage =>
      'Você precisa conceder permissão para selecionar imagens';

  @override
  String get trySelectAnyway => 'Tentar selecionar a imagem mesmo assim';

  @override
  String invoiceNumber(int number) {
    return 'Recibo #$number';
  }

  @override
  String get businessNameLabel => 'Nome do negócio';

  @override
  String get addressLabel => 'Endereço';

  @override
  String get phoneLabel => 'Telefone';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get productList => 'Lista de produtos';

  @override
  String get quantity => 'Quantidade';

  @override
  String get quantityShort => 'Qtd.';

  @override
  String get unitPrice => 'Preço';

  @override
  String get totalPrice => 'Total';

  @override
  String get receipt => 'Recibo';

  @override
  String receiptNumber(int number) {
    return 'Recibo #$number';
  }

  @override
  String get productsSuffix => 'Produtos:';

  @override
  String get totalSuffix => 'Total:';

  @override
  String get deleteReceipt => 'Excluir recibo';

  @override
  String deleteReceiptConfirm(int number) {
    return 'Tem certeza de que deseja excluir o Recibo #$number?\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get receiptDeleted => 'Recibo excluído';

  @override
  String get warningNeedPermissionsToShare =>
      '⚠️ Permissões necessárias para compartilhar';

  @override
  String get warningNeedPermissionsToDownload =>
      '⚠️ Permissões necessárias para baixar';

  @override
  String get successSavedToGallery => '✅ Salvo na galeria';

  @override
  String get searchByCustomerOrNumber => 'Buscar por cliente ou número...';

  @override
  String resultsCount(int count) {
    return '$count resultado(s)';
  }

  @override
  String get noReceiptsFound => 'Nenhum recibo encontrado';

  @override
  String productsCountLabel(int count) {
    return '$count produto(s)';
  }

  @override
  String get warningPermissionsDenied => '⚠️ Permissões negadas';

  @override
  String get successImageSelected => '✅ Imagem selecionada com sucesso';

  @override
  String get errorOccurred => '❌ Erro';

  @override
  String get successProductAdded => '✅ Produto adicionado com sucesso';

  @override
  String get successProductUpdated => '✅ Produto atualizado com sucesso';

  @override
  String errorWithMessage(String message) {
    return '❌ Erro: $message';
  }

  @override
  String get successOrderCreated => '✅ Pedido e recibo criados com sucesso';

  @override
  String get errorOrderCreation => '❌ Erro ao criar pedido';

  @override
  String get errorAddToOrder => '❌ Adicione pelo menos um produto ao pedido';

  @override
  String errorInsufficientStock(String product) {
    return '❌ Estoque insuficiente para $product';
  }

  @override
  String get totalLabel => 'Total:';

  @override
  String get minStockCharacters => 'O estoque mínimo é 0';

  @override
  String get maxStockValue => 'O estoque máximo é 999999';

  @override
  String get validStockRequired => 'Digite um estoque válido';

  @override
  String get minPriceValue => 'O preço mínimo é 0.01';

  @override
  String get maxPriceValue => 'O preço máximo é 99999999';

  @override
  String get validPriceRequired => 'Digite um preço válido';

  @override
  String get customerNameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get customerNameMaxLength => 'O nome é muito longo';

  @override
  String get phoneNumberInvalid => 'Número de telefone inválido';

  @override
  String get phoneMinLength => 'O telefone deve ter pelo menos 7 dígitos';

  @override
  String get downloadFormat => 'Formato de download';

  @override
  String get downloadFormatImage => 'Imagem (PNG)';

  @override
  String get downloadFormatPdf => 'Documento (PDF)';

  @override
  String get loginTitle => 'MeuNegócio';

  @override
  String get loginSubtitle => 'Sistema de Gestão';

  @override
  String get loginAsEmployee => 'Entrar como Funcionário';

  @override
  String get loginAsAdmin => 'Entrar como Admin';

  @override
  String get administrator => 'Administrador';

  @override
  String get password => 'Senha';

  @override
  String get verifying => 'Verificando...';

  @override
  String get defaultPassword => 'Senha padrão: 1234';

  @override
  String get pleaseEnterPassword => 'Por favor, digite a senha';

  @override
  String get incorrectPassword => 'Senha incorreta';

  @override
  String get loadingData => 'Carregando dados...';

  @override
  String get exportProducts => 'Exportar Produtos';

  @override
  String get importProducts => 'Importar Produtos';

  @override
  String get exportFullBackup => 'Exportar Tudo';

  @override
  String get importFullBackup => 'Importar Tudo';

  @override
  String get exportSuccess => 'Exportado com sucesso';

  @override
  String get importSuccess => 'Importado com sucesso';

  @override
  String get exportError => 'Erro ao exportar';

  @override
  String get importError => 'Erro ao importar';

  @override
  String get fileNotSelected => 'Nenhum arquivo selecionado';

  @override
  String get logout => 'Sair';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get sales => 'Vendas';

  @override
  String get today => 'Hoje';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get thisMonth => 'Este mês';

  @override
  String get allTime => 'Total';

  @override
  String invoicesCount(int count) {
    return '$count recibos';
  }

  @override
  String get topProducts => 'Produtos mais vendidos';

  @override
  String unitsSold(int count) {
    return '$count unidades vendidas';
  }

  @override
  String get stockAlerts => 'Alertas de Estoque';

  @override
  String get allGood => 'Tudo em ordem';

  @override
  String get noLowStockProducts => 'Nenhum produto com estoque baixo';

  @override
  String outOfStock(int count) {
    return 'Sem Estoque ($count)';
  }

  @override
  String lowStock(int count) {
    return 'Estoque Baixo ($count)';
  }

  @override
  String get noSalesRecorded => 'Nenhuma venda registrada';

  @override
  String get todayLabel => 'Hoje';

  @override
  String get weekLabel => 'Semana';

  @override
  String get monthLabel => 'Mês';

  @override
  String get allLabel => 'Tudo';

  @override
  String get customRange => 'Intervalo';

  @override
  String get selectRange => 'Selecionar intervalo';

  @override
  String get periodTotal => 'Total do período:';

  @override
  String get noBilletsInPeriod => 'Nenhum recibo neste período';

  @override
  String billetCount(int count) {
    return '$count recibo(s)';
  }

  @override
  String get filterToday => 'Hoje';

  @override
  String get filterWeek => 'Semana';

  @override
  String get filterMonth => 'Mês';

  @override
  String get filterAll => 'Tudo';

  @override
  String get filterRange => 'Intervalo';

  @override
  String get selectDateRange => 'Selecionar intervalo';

  @override
  String todayDate(String date) {
    return 'Hoje - $date';
  }

  @override
  String get thisWeekLabel => 'Esta semana';

  @override
  String thisMonthDate(String date) {
    return 'Este mês - $date';
  }

  @override
  String get allDates => 'Todas as datas';

  @override
  String get customRangeLabel => 'Intervalo personalizado';

  @override
  String dateRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String get clearAllFilters => 'Limpar filtros';

  @override
  String get noBilletsInPeriodShort => 'Nenhum recibo neste período';

  @override
  String get getStarted => 'Vamos Começar!';

  @override
  String get setupYourBusiness => 'Configure seu negócio para começar';

  @override
  String get businessSetup => 'Configuração Inicial';

  @override
  String get step => 'Passo';

  @override
  String get ofPreposition => 'de';

  @override
  String get businessInfo => 'Informações do Negócio';

  @override
  String get enterBusinessName => 'Nome do seu negócio';

  @override
  String get businessNameHint => 'Ex: Minha Loja';

  @override
  String get businessLogo => 'Logo (Opcional)';

  @override
  String get tapToAddLogo => 'Toque para adicionar logo';

  @override
  String get contactInfo => 'Informações de Contato';

  @override
  String get phoneNumber => 'Telefone';

  @override
  String get phoneHint => 'Ex: +55 11 98765-4321';

  @override
  String get emailAddress => 'E-mail';

  @override
  String get emailHint => 'exemplo@email.com';

  @override
  String get optionalField => '(Opcional)';

  @override
  String get preferences => 'Preferências';

  @override
  String get selectYourLanguage => 'Selecione seu idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get chinese => '中文';

  @override
  String get selectYourCurrency => 'Moeda';

  @override
  String get security => 'Segurança';

  @override
  String get createAdminPassword => 'Criar senha de administrador';

  @override
  String get passwordHint => 'Mínimo 6 caracteres';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get confirmPasswordHint => 'Repita a senha';

  @override
  String get passwordMismatch => 'As senhas não coincidem';

  @override
  String get passwordTooShort => 'Mínimo 6 caracteres';

  @override
  String get adminPasswordInfo => 'Proteja as funções de administrador';

  @override
  String get finish => 'Concluir';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get allSet => 'Tudo Pronto!';

  @override
  String get readyToStart => 'Seu negócio está pronto para começar';

  @override
  String get startNow => 'Começar Agora';

  @override
  String get proioApp => 'Proïon';

  @override
  String get businessManagementSystem => 'Sistema de Gestão';

  @override
  String get loginAsAdministrator => 'Entrar como Administrador';

  @override
  String get enterPassword => 'Senha';

  @override
  String get loginButton => 'Entrar como Admin';

  @override
  String get continueAsUser => 'Continuar como Usuário';

  @override
  String get userOnlyMode =>
      'Usuário: Apenas visualização e criação de pedidos';

  @override
  String get adminAccessRequired => 'Acesso de Administrador';

  @override
  String get adminLoginRequired =>
      'Você precisa fazer login como administrador';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get completeAllFields => 'Por favor, preencha todos os campos';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 4 caracteres';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get passwordConfiguredSuccessfully => 'Senha configurada com sucesso';

  @override
  String get errorConfiguringPassword => 'Erro ao configurar senha';

  @override
  String get initialSetup => 'Configuração Inicial';

  @override
  String get configureAdminPassword => 'Configure sua senha de administrador';

  @override
  String get firstTimeMessage =>
      'Esta é a primeira vez que você usa o aplicativo. Por favor, configure uma senha segura.';

  @override
  String get newPassword => 'Nova Senha';

  @override
  String get minimumCharacters => 'Mínimo 4 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirmar Senha';

  @override
  String get repeatPassword => 'Repita a senha';

  @override
  String get configureAndContinue => 'Configurar e Continuar';

  @override
  String get savePasswordSecurely => '🔒 Guarde esta senha em um lugar seguro';

  @override
  String get loading => 'Carregando...';

  @override
  String get legalDisclaimer =>
      '⚠️ Este recibo é apenas para controle interno. Não constitui um comprovante fiscal válido.';

  @override
  String get adminOnly => 'Apenas Administrador';

  @override
  String get adminOnlyCurrencyMessage =>
      'Apenas o Administrador pode alterar a moeda do negócio.';

  @override
  String get understood => 'Entendido';

  @override
  String minNameCharacters(int count) {
    return 'O nome deve ter pelo menos $count caracteres';
  }

  @override
  String get nameTooLong => 'O nome é muito longo';

  @override
  String get invalidPhoneNumber => 'Número de telefone inválido';

  @override
  String unexpectedError(String error) {
    return 'Erro inesperado: $error';
  }

  @override
  String get logoSelectedSuccess => 'Logo selecionado com sucesso';

  @override
  String errorSelectingImage(String error) {
    return 'Erro ao selecionar imagem: $error';
  }

  @override
  String get profileUpdatedSuccess => 'Perfil atualizado com sucesso';

  @override
  String get errorSavingProfile => 'Erro ao salvar o perfil';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortByName => 'Nome';

  @override
  String get sortByPrice => 'Preço';

  @override
  String get sortByStock => 'Estoque';

  @override
  String get sortByDate => 'Data';

  @override
  String get sortByTotal => 'Total';

  @override
  String get sortByInvoiceNumber => 'Número do recibo';

  @override
  String get ascending => 'Ascendente';

  @override
  String get descending => 'Descendente';

  @override
  String get backup => 'Backup';

  @override
  String get backupAndRestore => 'Backup e Restauração';

  @override
  String get exportData => 'Exportar Dados';

  @override
  String get importData => 'Importar Dados';

  @override
  String get exportInvoices => 'Exportar Recibos';

  @override
  String get importInvoices => 'Importar Recibos';

  @override
  String get backupType => 'Tipo de Backup';

  @override
  String get quickBackup => 'Rápido (apenas dados)';

  @override
  String get quickBackupDesc => '~100 KB • Instantâneo • Sem imagens';

  @override
  String get fullBackup => 'Completo (com imagens)';

  @override
  String get fullBackupDesc => '~5-10 MB • Inclui fotos • Mais lento';

  @override
  String exportSuccessMessage(int count) {
    return '$count itens exportados';
  }

  @override
  String get exportFailed => 'Erro ao exportar';

  @override
  String importSuccessMessage(int imported, int replaced) {
    return '$imported novos, $replaced substituídos';
  }

  @override
  String get importFailed => 'Erro ao importar';

  @override
  String get fileLocation => 'Localização do arquivo';

  @override
  String get fileSize => 'Tamanho';

  @override
  String get itemsExported => 'Itens exportados';

  @override
  String get itemsImported => 'Itens importados';

  @override
  String get itemsReplaced => 'Itens substituídos';

  @override
  String get itemsSkipped => 'Itens ignorados';

  @override
  String get itemsFailed => 'Itens com falha';

  @override
  String get selectBackupFile => 'Selecionar arquivo de backup';

  @override
  String get invalidBackupFile => 'Arquivo de backup inválido';

  @override
  String get backupFileNotFound => 'Arquivo não encontrado';

  @override
  String get confirmImport => 'Confirmar importação?';

  @override
  String confirmImportMessage(int count) {
    return '$count itens serão importados. Duplicados serão substituídos.';
  }

  @override
  String get lastBackup => 'Último backup';

  @override
  String get neverBackedUp => 'Nunca';

  @override
  String get backupNow => 'Fazer backup agora';

  @override
  String get restoreNow => 'Restaurar agora';

  @override
  String get openFolder => 'Abrir pasta';

  @override
  String get backupInProgress => 'Fazendo backup...';

  @override
  String get importInProgress => 'Importando...';

  @override
  String get logoutConfirmMessage => 'Tem certeza que deseja sair?';

  @override
  String get logoutSubtitle => 'Fechar sessão atual';

  @override
  String get admin => 'Administrador';

  @override
  String get user => 'Usuário';

  @override
  String get selectRole => 'Selecionar Função';

  @override
  String get switchToUser => 'Mudar para Usuário';

  @override
  String get switchToUserSubtitle => 'Modo de acesso limitado';

  @override
  String get switchToAdmin => 'Mudar para Administrador';

  @override
  String get switchToAdminSubtitle => 'Requer senha';

  @override
  String get productNameCannotBeEmpty =>
      'O nome do produto não pode estar vazio';

  @override
  String get productDuplicatePrefix => 'Já existe um produto com o nome';

  @override
  String get anotherProductDuplicatePrefix =>
      'Já existe outro produto com o nome';

  @override
  String get selectPage => 'Ir para página';

  @override
  String get pageNumber => 'Número da página';

  @override
  String get invalidPage => 'Página inválida';

  @override
  String get go => 'Ir';

  @override
  String get scrollMode => 'Modo Rolagem';

  @override
  String get pageMode => 'Modo Páginas';

  @override
  String get goToPage => 'Ir para página...';

  @override
  String get totalProducts => 'produtos totais';

  @override
  String get page => 'Página';

  @override
  String get loadingMoreProducts => 'Carregando mais produtos...';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Próxima página';

  @override
  String get myBackups => 'Meus Backups';

  @override
  String get myBackupsSubtitle => 'Gerenciar backups de produtos e faturas';

  @override
  String invoiceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recibos',
      one: '1 recibo',
    );
    return '$_temp0';
  }

  @override
  String get loadingMoreInvoices => 'Carregando mais faturas...';

  @override
  String confirmDeleteInvoice(String receipt, int number) {
    return 'Tem certeza de que deseja excluir $receipt #$number?\n\nEsta ação não pode ser desfeita.';
  }

  @override
  String get savedSuccessfully => '✅ Arquivo salvo com sucesso';

  @override
  String get view => 'Ver';

  @override
  String get couldNotOpenFile => 'Não foi possível abrir o arquivo';
}
