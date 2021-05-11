var table;


var loopCheckItem = 0;
$(document).ready(function () {

    var table = $('#dt-registro').DataTable(
        {
            'columnDefs': [{ "orderable": false, "targets": -1 }],
            "order": [[1, "asc"]],
            orderCellsTop: true,
            fixedHeader: true,
            dom: "<'row mb-3'<'col-sm-12 col-md-6 d-flex align-items-center justify-content-start'B><'col-sm-12 col-md-6 d-flex align-items-center justify-content-end'l>>" +
                "<'row'<'col-sm-12'tr>>" +
                "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
            "responsive": true,
            "processing": true,
            "serverSide": true,
			buttons: [
				{
					text: 'Boletos Pendentes',
					className: 'btn btn-outline-primary waves-effect waves-themed',
					action: function (e, dt, node, config) {
						window.location.href = UrlBase + '/BoletoPendente'
					}
				}
			],
            "ajax": {
                "url": UrlBase + "/DataTable",
                "type": "POST",
                "datatype": "json",
                "data": {
                    FieldSearch: function () {
                        return $('input[name=FieldSearch]').val()
                    },
                },
            },

            "columns": [

                {
                    "data": "cpfcnpj", "name": "CPFCNPJ"
                },
                {
                    "data": "codigoERP", "name": "CodigoERP"
                },
                {
                    "data": "nome", "name": "Nome"
                },
                {
                    "data": "email", "name": "Email"
                },
                {
                    "data": "bairro", "name": "Bairro"
                },
                {
                    "data": "cidade", "name": "Cidade"
                },
                {
                    "data": "uf", "name": "UF"
                },
                {
                    "render": function (data, type, full, meta) {


                        var html = '<a title="Criar/Resetar Usuário" href="javascript:void(0)" pessoaid="' + full.id + '" empresaid="' + full.empresaID + '" class="btn btn-icon fs-xl waves-effect waves-themed btn-criar-reset" >'
                        html += '<i class="fal fa-user color-fusion-300"></i>'
                        html += '</a>'

                        return html;
                    }
                }
            ],
            "lengthMenu": [[10, 20, 30, -1], [10, 20, 30, "All"]],
            "aaSorting": [],
            "oLanguage": {
                "oPaginate": {
                    "sNext": ">",
                    "sFirst": "<<",
                    "sLast": ">>",
                    "sPrevious": "<"
                },
                "sLengthMenu": "Mostrar:  _MENU_",
                "sZeroRecords": "Não há registros correspondentes foram encontrados",
                "sInfo": "Mostrando _START_ a _END_ de _TOTAL_ no total",
                "sInfoEmpty": "Mostrando 0 a 0 de 0 no total",
                "sInfoFiltered": "(filtrado das _MAX_ entradas totais)",
                "sSearch": "Filtrar: ",
                "sEmptyTable": "Não há dados disponíveis na tabela",
                "sLoadingRecords": "Carregando...",
                "sProcessing": "Processando..."
            },
        });


    var CamposFiltro = ['CPFCNPJ', 'CodigoERP', 'Nome', 'Email', 'Bairro', 'Cidade', 'UF'];
    $('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
    $('#dt-registro thead tr:eq(1) th').each(function (i) {

        $(this).removeClass('sorting');
        if (i < CamposFiltro.length) {

            var title = $(this).text();
            $(this).html('<div class="form-check-inline" style="width: 100%;"><div class="" style="width: 100%;"><input type="text" name="' + CamposFiltro[i] + '" class="form-control form-control-sm search" placeholder=""></div><div class=""><div class="columnFilter filter-search"><i class="fal fa-filter mr-1"></i></div></div>');


            $('input', this).on('keyup', function (e) {
                if (e.keyCode == 13) {
                    FuncSearch(this, table);
                }
            });
        } else {
            $(this).html('');
        }
    });

    $('.filter-search').on('click', function () {
        FuncSearch(this, table);
    });


    $('#dt-registro').on('click', '.btn-criar-reset', function () {
		RegisterOrResetAsync($(this).attr('empresaid'), $(this).attr('pessoaid'))
    });
});



function RegisterOrResetAsync(empresaId, pessoaId) {
    $.get(
        '../Account/RegisterOrResetAsync',
		{ empresaId: empresaId, pessoaId: pessoaId, tipo: 2 },
        function (d) {
            Swal.fire({
                type: d.ok ? 'success' : 'error',
                title: "",
                text: d.ok ? 'Usuário criado/resetado com sucesso.' : 'Erro ao criar/resetar usuário.',
            });
        }
    );
}