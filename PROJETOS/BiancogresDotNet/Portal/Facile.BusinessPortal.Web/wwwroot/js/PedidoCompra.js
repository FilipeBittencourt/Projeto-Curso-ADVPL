var table;


var loopCheckItem = 0;
$(document).ready(function () {

    table = $('#dt-registro').DataTable(
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
              /*  {
                    text: '<i class="fal fa-calendar-plus mr-1"></i> Agendar',
                    className: 'btn btn-outline-primary waves-effect waves-themed',
                    action: function (e, dt, node, config) {
                        ListarAgendar();
                    }
                },
                {
                    text: '<i class="fal fa-search mr-1"></i> Visualizar Agendado',
                    className: 'btn btn-outline-primary waves-effect waves-themed',
                    action: function (e, dt, node, config) {
                        VisualizarAgendar();
                    }
                }
                */
			],
            "ajax": {
                "url": "../Compra/PedidoCompra/DataTable",
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
                    "render": function (data, type, full, meta) {
                        var html = '<div class="custom-control custom-checkbox mr-3 order-1 check-item">'
                        html += '<input type="hidden" name="Id" value="' + full.id + '">'
                        html += '<input type="checkbox" name="checkItem" class="custom-control-input" id="checkItem' + loopCheckItem + '">'
                        html += '<label class="custom-control-label" for="checkItem' + loopCheckItem + '"></label>'
                        html += '</div>'
                        loopCheckItem++;
                        return html;
                    }
                },
                {
                    "data": "fornecedor", "name": "Fornecedor"
                },
                {
                    "data": "numero", "name": "Numero"
                },
                {
                    "data": "item", "name": "Item"
                },
                {
                    "data": "produto", "name": "Produto"
                },
                {
                    "data": "quantidade", "name": "Quantidade"
                },
                {
                    "data": "saldo", "name": "Saldo"
                },
                {
                    "render": function (data, type, full, meta) {

                        var html = ""

                        html += '<a target="_blank" title="Detalhe" href="../compra/pedidocompra/details/' + full.id + '" registroid="' + full.id + '" class="btn btn-icon fs-xl waves-effect waves-themed" >'
                        html += '<i class="fal fa-file-alt color-fusion-300"></i>'
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


    var CamposFiltro = ['', 'Fornecedor', 'Numero', 'Item', 'Produto', 'Quantidade', 'Saldo', ''];
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

    $('.btn-agendar').on('click', function () {
        Agendar()
    });

    
    $('#dt-registro').on('click', '.btn-criar-reset', function () {

    });

});

function VisualizarAgendar() {
    $('.new-page')[0].click();
}


function ListarAgendar() {
    
    var el = $('input[name=checkItem]');
    var Id = 0;
    for (var i = 0; i < el.length; i++) {
        if ($(el[i]).prop('checked')) {
            Id = $(el[i]).closest('div.check-item').find('input[name="Id"]').val();
            break;
        }
    }

    if (Id != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.get(
            "../Compra/PedidoCompra/GetNotaFiscal",
            { q: Id },
            function (d) {
                $('#preloader').addClass('hide');
                var html = "";

                  for (var i = 0; i < d.items.length; i++) {

                      var htmlcheck = '<div class="custom-control custom-checkbox mr-3 order-1">'
                      htmlcheck += '<input type="hidden" name="Id" value="' + d.items[i].id + '">'
                    htmlcheck += '<input type="checkbox" name="checkItemNota" class="custom-control-input" id="checkItemNota' + i + '">'
                    htmlcheck += '<label class="custom-control-label" for="checkItemNota' + i + '"></label>'
                    htmlcheck += '</div>'


                    html += '<tr>'
                    html += '<td>' + htmlcheck + '</td>'

                    html += '<td>' + d.items[i].numero + '/' + d.items[i].serie + '</td>'
                    html += '<td>' + d.items[i].dataEmissao + '</td>'
                  //  html += '<td>' + d.items[i].pedido + '/' + d.items[i].item + '</td>'
                    html += '<td class="text-right">' + d.items[i].quantidade.toFixed(2) + '</td>'
                    html += '</tr>'
                }
                $('#table-detalhe-nota-fiscal tbody').html(html);

                $('#modal-detalhe-nota-fiscal').modal('show');

            },
            'JSON'
        );

    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Selecione um registro.",
        });
    }   
    
}

function Agendar() {
    $('#modal-detalhe-nota-fiscal').modal('hide');
    $('#modal-agendamento-calendario').modal('show');
//$('#modal-agendamento').modal('show');
}

