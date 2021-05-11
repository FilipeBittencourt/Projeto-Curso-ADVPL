
$(function () {
	LoadSelect2Produto("form[name=cadSolicitacaoServico] select[name='ServicoID']");
	LoadSelect2Forn("form[name=cadSolicitacaoFornecedor] select[name='FornecedorID']");

	LoadSelect2Tag("form[name=cadSolicitacaoServico] select[name='ServicoTag']")
	LoadSelect2Driver("form[name=cadSolicitacaoServico] select[name='ServicoDriver']")

	LoadSelect2ItemConta("form[name=FormCad] select[name='ItemContaID']")
	LoadSelect2SubItemConta("form[name=FormCad] select[name='SubItemContaID']")
	LoadSelect2Contrato("form[name=FormCad] select[name='ContratoID']")
	LoadSelect2SetorAprovacao("form[name=FormCad] select[name='SetorAprovacaoID']")

	LoadSelect2ContaContabil("form[name=cadSolicitacaoServico] select[name='ServicoContaContabil']")

	LoadSelect2Usuario("form[name=FormCad] select[name='UsuarioOrigemID']")
	LoadSelect2Usuario("form[name=FormCad] select[name='UsuarioMedicaoID']")


	LoadSelect2Cliente("form[name=cadSolicitacaoServico] select[name='ServicoCodigoCliente']")

});


function LoadSelect2Produto(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetProduto",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#cadSolicitacaoServico'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoProduto,
			templateSelection: formatRepoSelectionProduto
		}).change(function (el) {

			var data = $(el.target).select2('data')
			if (data.length > 0) {
				$('#cadSolicitacaoServico').find('input[name="ServicoDescricao"]').val(data[0].nome)
				$('#cadSolicitacaoServico').find('input[name="ServicoClassificaoContabil"]').val(data[0].classificacaoFiscal)
			}

		});
}

function formatRepoProduto(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";
	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.classificacaoFiscal + "</div>";


	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionProduto(repo) {


	return repo.codigo || repo.text || '';
}

function LoadSelect2Forn(el) {
	var o = el || ".select2"

	$(o).select2(
		{
			ajax: {
				url: "/AdminEmpresa/Fornecedor/GetFornecedorCNPJ",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#cadSolicitacaoFornecedor'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoForn,
			templateSelection: formatRepoSelectionForn
		}).change(function (el) {

			var data = $(el.target).select2('data')
			if (data.length > 0) {
				$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorNome']").val(data[0].nome);
				$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorContato']").val(data[0].contato);
				$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorEmail']").val(data[0].email);
				$("form[name=cadSolicitacaoFornecedor] input[name='FornecedorTelefone']").val(data[0].telefone);
			}

		});
}

function formatRepoForn(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.cpfcnpj + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";
	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.razaoSocial + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionForn(repo) {

	return repo.cpfcnpj || repo.text || '';
}

function LoadSelect2Driver(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetDriver",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#cadSolicitacaoServico'),
				data: function (params) {
					return {
						q: params.term, // search term
						ClasseValorID: $('select[name=ClasseValorID]').val(),
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoDriver,
			templateSelection: formatRepoSelectionDriver
		}).change(function (el) {

			var data = $(el.target).select2('data')
			
		});
}

function formatRepoDriver(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionDriver(repo) {

	if (repo.codigo)
		return repo.codigo + ' - ' + repo.descricao
	else
		repo.text || ''
}

function LoadSelect2Tag(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetTag",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#cadSolicitacaoServico'),
				data: function (params) {
					return {
						q: params.term, // search term
						ClasseValorID: $('select[name=ClasseValorID]').val(),
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoTag,
			templateSelection: formatRepoSelectionTag
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoTag(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionTag(repo) {

	if (repo.codigo)
		return repo.codigo + ' - ' + repo.descricao
	else
		repo.text || ''
}

function LoadSelect2ItemConta(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetItemConta",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoItemConta,
			templateSelection: formatRepoSelectionItemConta
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoItemConta(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionItemConta(repo) {

	return repo.codigo || repo.text || '';
}

function LoadSelect2SubItemConta(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetSubItemConta",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						ClasseValorID: $('select[name=ClasseValorID]').val(),
						ItemContaID: $('select[name=ItemContaID]').val(),
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoSubItemConta,
			templateSelection: formatRepoSelectionSubItemConta
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoSubItemConta(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionSubItemConta(repo) {

	return repo.codigo || repo.text || '';
}

function LoadSelect2ContaContabil(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetContaContabil",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#cadSolicitacaoServico'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoContaContabil,
			templateSelection: formatRepoSelectionContaContabil
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoContaContabil(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionContaContabil(repo) {

	return repo.codigo || repo.text || '';
}

function LoadSelect2Contrato(el) {

	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetContrato",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoContrato,
			templateSelection: formatRepoSelectionContrato
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoContrato(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionContrato(repo) {

	return repo.codigo || repo.text || '';
}

function LoadSelect2SetorAprovacao(el) {

	var o = el; // || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetSetorAprovacao",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						ClasseValorID: $('select[name=ClasseValorID]').val(),
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoSetorAprovacao,
			templateSelection: formatRepoSelectionSetorAprovacao
		}).change(function (el) {

			var data = $(el.target).select2('data')

		});
}

function formatRepoSetorAprovacao(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.descricao + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionSetorAprovacao(repo) {

	return repo.codigo || repo.text || '';
}

function LoadSelect2Usuario(el) {
	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetUsuario",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoUsuario,
			templateSelection: formatRepoSelectionUsuario
		}).change(function (el) {

			var data = $(el.target).select2('data');

		});
}

function formatRepoUsuario(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.nome + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionUsuario(repo) {

	return repo.nome || repo.text;
}


function LoadSelect2Cliente(el) {
	var o = el || ".select2"
	$(o).select2(
		{
			ajax: {
				url: "/Compra/SolicitacaoServicoUtil/GetCliente",
				dataType: 'json',
				//delay: 250,
				dropdownParent: $('#FormCad'),
				data: function (params) {
					return {
						q: params.term, // search term
						page: params.page
					};
				},
				processResults: function (data, params) {
					params.page = params.page || 1;
					return {
						results: data.items,
						pagination:
						{
							more: (params.page * 30) < data.total_count
						}
					};
				},
				cache: true
			},
			"language": {
				"searching": function () {
					return "procurando...";
				},
				"inputTooShort": function (args) {
					var remainingChars = args.minimum - args.input.length;

					var message = 'Insira ' + remainingChars + ' ou  mais caracteres';

					return message;
				},
			},
			placeholder: 'Selecione...',
			escapeMarkup: function (markup) {
				return markup;
			}, // let our custom formatter work
			minimumInputLength: 1,
			templateResult: formatRepoCliente,
			templateSelection: formatRepoSelectionCliente
		}).change(function (el) {

			var data = $(el.target).select2('data');

		});
}

function formatRepoCliente(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

//	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelectionCliente(repo) {

	return repo.codigo || repo.text;
}