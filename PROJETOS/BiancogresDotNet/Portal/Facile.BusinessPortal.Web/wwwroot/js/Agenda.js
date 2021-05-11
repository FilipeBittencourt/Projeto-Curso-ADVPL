var calendar = null;
var events = []
function loadCalendar() {
    var calendarEl = document.getElementById('calendar');

    calendar = new FullCalendar.Calendar(calendarEl,
        {
            locale: 'pt-br',
            firstDay: 1,
            aspectRatio: 1.6,
            fixedWeekCount: false,
            eventLimit: true,
            plugins: ['dayGrid', 'list', 'timeGrid', 'interaction', 'bootstrap'],
            themeSystem: 'bootstrap',
            timeZone: 'UTC',
            dateAlignment: "month", //week, month
            buttonText:
            {
                today: 'Hoje',
                month: 'Mês',
                week: 'Semana',
                day: 'Dia',
                list: 'Lista'
            },
            eventTimeFormat:
            {
                hour: 'numeric',
                minute: '2-digit',
                meridiem: 'short'
            },
            navLinks: true,
            header:
            {
                left: 'prev,next today addEventButton',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek'
            },
            footer:
            {
                left: '',
                center: '',
                right: ''
            },
            customButtons:
            {

            },
            // height: 700,
            editable: true,
            eventLimit: true, // allow "more" link when too many events

            events: function (info, successCallback) {

                $.get(
                    "../Compra/PedidoCompra/GetAgenda",
                    {
                        start: moment(info.start).format("YYYY-MM-DD"),
                        end: moment(info.end).format("YYYY-MM-DD")
                    },
                    function (d) {
                        if (d.ok == 1) {
                            successCallback(d.events);
                        }
                    },
                    'JSON'
                );

            },
            eventRender: function (info) {
                var classNames = info.event.classNames

                for (var i = 0; i < classNames.length; i++) {
                    if (classNames[i] == 'not-available') {
                        events.push(moment(info.event.start).utc().format('DD/MM/YYYY'))
                    }
                }

            },

            dateClick: function (info) {

                for (var i = 0; i < events.length; i++) {
                    if (events[i] == moment(info.dateStr).format('DD/MM/YYYY')) {
                        return
                    }
                }

                /*var el = $('#table-detalhe-nota-fiscal tr');
                var html = "<p>Notas fiscais: </p>"
                var IdNotaFiscais = "";
                for (var i = 0; i < el.length; i++) {
                    if ($(el[i]).find('input[name=checkItemNota]').prop('checked')) {
                        html += "<p>" + $(el[i]).find('td:nth-child(2)').text() + "</p>";

                        if (IdNotaFiscais != "") {
                            IdNotaFiscais += ","
                        }

                        IdNotaFiscais += $(el[i]).find('input[name=Id]').val();
                    }
                }
                $('form[name=cadAgendamento] input[name=IdNotaFiscais]').val(IdNotaFiscais);
                $('.nota-fiscal-agendamento').html(html);
                */

                $('input[name=DataAgendamento]').val(moment(info.dateStr).format('DD/MM/YYYY'));
                $('form[name=cadAgendamento] input[name=HoraAgendamento]').val('');
                $('form[name=cadAgendamento] textarea[name=Observacao]').val('');
                $('#modal-agendamento').css('z-index', 2060);
                $('#modal-agendamento').modal('show');

            }

        });

    calendar.render();

}

$(function () {

    
    $('#dt-registro').on('click', '.btn-modal-agenda', function () {
        $('#modal-agendamento-calendario').modal('show');
        var Id = $(this).attr('registroid')
        $('form[name=cadAgendamento] input[name=IdNotaFiscais]').val(Id);
    });

    $('#modal-agendamento-calendario').on('show.bs.modal', function (e) {
        $(".modal").css("overflow-y", "scroll");
        events = []
        if (calendar == null) {
            setTimeout(function () { loadCalendar() }, 300);
        } else {
            calendar.refetchEvents()
        }

    });

    $('.btn-salvar-agendamento').on('click', function () {
        VerificarDisponibilidade(function () { SalvarAgendamento() });
    });

});


function VerificarDisponibilidade(func) {
    var IdNotaFiscais = $('form[name=cadAgendamento] input[name=IdNotaFiscais]').val();
    var DataAgendamento = $('form[name=cadAgendamento] input[name=DataAgendamento]').val();
    
    if (DataAgendamento != "" && IdNotaFiscais != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.get(
            "../Compra/PedidoCompra/VerificarDisponibilidade",
            {
                IdNotaFiscais: IdNotaFiscais, DataAgendamento: DataAgendamento
            },
            function (d) {
                $('#preloader').addClass('hide');

                if (d.ok) {
                    func.call();
                } else {
                    type = "error"
                    text = d.mensagem
                    Swal.fire({
                        type: type,
                        title: "",
                        text: text,
                    });
                    $('.swal2-container').css('z-index', 3000);
                }


            },
            'JSON'
        );

    } else {
        Swal.fire({
            type: "error",
            title: "",
            text: "Informe a Data/Notas Fiscais para o agendamento.",
        });
        $('.swal2-container').css('z-index', 3000);
    }
}

function SalvarAgendamento() {

    var IdNotaFiscais = $('form[name=cadAgendamento] input[name=IdNotaFiscais]').val();
    var DataAgendamento = $('form[name=cadAgendamento] input[name=DataAgendamento]').val();
    var HoraAgendamento = $('form[name=cadAgendamento] input[name=HoraAgendamento]').val();
    var Observacao = $('form[name=cadAgendamento] textarea[name=Observacao]').val();
    
    if (DataAgendamento != "" && HoraAgendamento != "" && IdNotaFiscais != "") {
        $('#preloader').removeClass('hide');
        $('#preloader div#status').html('Aguarde...');

        $.post(
            "../Compra/PedidoCompra/SalvarAgendamento",
            {
                IdNotaFiscais: IdNotaFiscais, DataAgendamento: DataAgendamento, HoraAgendamento: HoraAgendamento,
                Observacao: Observacao
            },
            function (d) {
                $('#preloader').addClass('hide');

                if (d.ok) {
                    $('#modal-agendamento-calendario').modal('hide');
                    $('#modal-agendamento').modal('hide');

                    type = "success";
                    text = "Agendamento realizado com sucesso.";
                    table.ajax.reload();
                } else {
                    type = "error"
                    text = d.mensagem
                }

                Swal.fire({
                    type: type,
                    title: "",
                    text: text,
                });
                $('.swal2-container').css('z-index', 2070);

            },
            'JSON'
        );
    } else {

        Swal.fire({
            type: "error",
            title: "",
            text: "Informe a Data/Hora/Notas Fiscais para o agendamento.",
        });
        $('.swal2-container').css('z-index', 2070);

    }
}