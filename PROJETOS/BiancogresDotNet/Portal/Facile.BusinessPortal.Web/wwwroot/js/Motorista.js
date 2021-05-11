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
                    text: 'Novo',
                    className: 'btn btn-outline-primary waves-effect waves-themed',
                    action: function (e, dt, node, config) {
                        window.location.href = linkNovo;
                    }
                }
			],
            "ajax": {
                "url": "../Compra/Motorista/DataTable",
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
                    "data": "nome", "name": "Nome"
                },
                {
                    "data": "cpf", "name": "CPF"
                },
                {
                    "data": "cnh", "name": "CNH"
                },
                {
                    "data": "placa", "name": "Placa"
                },
                {
                    "data": "descricaoStatus", "name": "DescricaoStatus"
                },
                {
                    "render": function (data, type, full, meta) {

                        var html = ''
                        html += '<a title="Editar" class="btn btn-icon waves-effect waves-themed"  href="../compra/motorista/edit/' + full.id + '" >'
                        html += '    <i class="fal fa-pencil text-info"></i>'
                        html += '</a>'
                        html += '<a title="Excluir" class="btn btn-icon waves-effect waves-themed"  href="../compra/motorista/delete/' + full.id + '">'
                        html += '    <i class="fal fa-trash color-fusion-300"></i>'
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


    var CamposFiltro = ['Nome', 'CPF', 'CNH', 'Placa', 'DescricaoStatus', ''];
    $('#dt-registro thead tr').clone(false).appendTo('#dt-registro thead');
    $('#dt-registro thead tr:eq(1) th').each(function (i) {

        $(this).removeClass('sorting');
        if (CamposFiltro[i] != "") {

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


});