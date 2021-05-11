
var total = 0;
function addRow(idtabela, tipo, nome, id, valor, style, outros, estiloCell, colspanCell) {
	total++;
	var tbl = document.getElementById(idtabela);
	var novaLinha = tbl.insertRow(-1);
	var novaCelula;
	var conteudo;

	var classCelula = "";
	for (var l = 0; l < tipo.length; l++) {

		switch (tipo[l]) {
			case "text":
				conteudo = "<input type='text' name='" + nome[l] + "' value='" + valor[l] + "' id='" + id[l] + "' " + outros[l] + " class='" + style[l] + "'/>"
				break;
			case "hidden":
				conteudo = "<input type='hidden' name='" + nome[l] + "' value='" + valor[l] + "' id='" + id[l] + "' " + outros[l] + " class='" + style[l] + "'/>"
				break;
			case "checkbox":
				conteudo = "<label><input name='" + nome[l] + "' id='" + id[l] + "' value='" + valor[l] + "' type='checkbox' class='" + style[l] + "'  " + outros[l] + "><span class='lbl'>&nbsp; </span></label>";
				break;
			case "file":
				conteudo = "<div class='custom-file' " + outros[l] + ">"
				conteudo += "	<input type='file' name='" + nome[l] + "' class='" + style[l] + "' id='" + id[l] + "'>"
				conteudo += "		<label class='custom-file-label' for='" + id[l] + "'>Selecionar Arquivo</label>"
				conteudo += "</div>"
				//conteudo = "<input type='file' name='" + nome[l] + "' value='" + valor[l] + "' id='" + id[l] + "' class='" + style[l] + "' " + outros[l] + "/>";
				break
			case "textarea":
				conteudo = "<textarea name='" + nome[l] + "' " + outros[l] + ">" + valor[l] + "</textarea>"
				break;
			case "select":

				conteudo = "<select name='" + nome[l] + "' class='" + style[l] + "' id='" + id[l] + "' " + outros[l] + ">";
				for (var x = 0; x < valor[l].length; x++) {
					conteudo += "<option value='" + valor[l][x][0] + "'>" + valor[l][x][1] + "</option>";
				}
				conteudo += "</select>";
				break;

			case "html":
				conteudo = valor[l];
				break

			case "":
				conteudo = nome[l];
				break
		}
		classCelula = estiloCell[l];
		novaCelula = novaLinha.insertCell(l);
		//novaCelula.align = "left";
		novaCelula.className = classCelula;
		$(novaCelula).attr('colspan', colspanCell[l]);
		//novaCelula.style.background = cl;
		novaCelula.innerHTML = conteudo;
	}
}


function formatSearch(id) {

	var els = $('#'+id).find('input.search');
	var search = "";

	for (var i = 0; i < els.length; i++) {
		var v = $(els[i]).val();

		if (v != "") {
			search += $(els[i]).attr('name') + '=' + v + '|';
		}
	}

	$('input[name=FieldSearch]').val(search);

}

function checkCheckBox(o) {
	var el = o;

	var check = $("#" + el + " input[type='checkbox']");
	for (var i = 0; i < check.length; i++) {
		if (check[i].checked) {
			check[i].value = true;
		} else {
			check[i].value = false;
			check[i].checked = true;
		}
	}
}


function FuncSearch(el, table) {
	
	if ($(el).closest('th').find('i').hasClass('filter-ativo')) {
		if ($(el).prop("tagName") != 'INPUT') {
			$(el).closest('th').find('input').val('');
		}
	}
		
	var val = $(el).closest('th').find('input').val();
		
	$(el).closest('th').find('i').removeClass('filter-ativo');
	if (val != "") {
		$(el).closest('th').find('i').addClass('filter-ativo');
	}

	formatSearch('dt-registro');
	table.ajax.reload();
}



function LoadSelect2Fornecedor(el) {
	var o = el || ".select2"
	$(o).select2(
		{
			ajax:{
				url: "../AdminEmpresa/Fornecedor/GetFornecedor",
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
			templateResult: formatRepo,
			templateSelection: formatRepoSelection
		}).change(function (el) {

			var data = $(el.target).select2('data')
			if (data.length > 0) {
				$(el.target).closest('tr').find('input[name="NomeFornecedor"]').val(data[0].nome)
			}

		});
}

function formatRepo(repo) {
	if (repo.loading) {
		return repo.text;
	}

	var markup = "<div class='select2-result-repository clearfix d-flex'>" +
		"<div class='select2-result-repository__meta'>" +
		"<div class='select2-result-repository__title fs-lg fw-500'>" + repo.codigo + "</div>";

	markup += "<div class='select2-result-repository__description fs-xs opacity-80 mb-1'>" + repo.nome + "</div>";

	markup += "<div class='select2-result-repository__statistics d-flex fs-sm'>" +
		"<div class='select2-result-repository__forks mr-2'></div>" +
		"<div class='select2-result-repository__stargazers mr-2'></div>" +
		"<div class='select2-result-repository__watchers mr-2'></div>" +
		"</div>" +
		"</div></div>";

	return markup;
}

function formatRepoSelection(repo) {

	return repo.codigo ? repo.codigo + ' - ' + repo.nome : repo.nome;
}




$(function () {

	$('#dt-registro').on('click', '#checkAll', function () {
		var check = $('#checkAll').is(':checked')

		var el = $('input[name="checkItem"]');
		for (var i = 0; i < el.length; i++) {
			$(el[i]).prop('checked', check);
		}

	});

	$('.data-datepicker').datepicker({
		todayHighlight: true,
		format: "dd/mm/yyyy",
		templates: {
			leftArrow: '<i class="fal fa-angle-left" style="font-size: 1.25rem"></i>',
			rightArrow: '<i class="fal fa-angle-right" style="font-size: 1.25rem"></i>'
		}
	}).on('change', function () {
		$('.datepicker').hide();
	});


});


function isValidDate (data) {
	// Ex: 10/01/1985
	var regex = "\\d{2}/\\d{2}/\\d{4}";
	var dtArray = data.split("/");

	if (dtArray == null)
		return false;

	// Checks for dd/mm/yyyy format.
	var dtDay = dtArray[0];
	var dtMonth = dtArray[1];
	var dtYear = dtArray[2];

	if (dtMonth < 1 || dtMonth > 12)
		return false;
	else if (dtDay < 1 || dtDay > 31)
		return false;
	else if ((dtMonth == 4 || dtMonth == 6 || dtMonth == 9 || dtMonth == 11) && dtDay == 31)
		return false;
	else if (dtMonth == 2) {
		var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
		if (dtDay > 29 || (dtDay == 29 && !isleap))
			return false;
	}
	return true;
}
//funcoes prototypes

Number.prototype.formatNumber = function (places, symbol, thousand, decimal) {
	places = !isNaN(places = Math.abs(places)) ? places : 2;
	symbol = symbol !== undefined ? symbol : "$";
	thousand = thousand || ",";
	decimal = decimal || ".";
	var number = this,
		negative = number < 0 ? "-" : "",
		i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
		j = (j = i.length) > 3 ? j % 3 : 0;
	return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
};

