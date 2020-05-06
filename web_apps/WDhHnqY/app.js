


$('#run_flow').on('click', function(){
    $('#df_table table').remove()
    $('#df_table').hide()
    var flow_runner = run_scenario()
})

load_filters()

function load_filters(){
    var flow_run =$.getJSON(getWebAppBackendUrl('get_variables'),function(data){
        $.each(data, function(index,value){
            $('.panel-body').prepend('<input type="text" class="form-control" id="'+value+'" placeholder="'+value+'" value="" required=""></input>')
        })
        
    })
    
}

function run_scenario() {
    /* showing the loading screen */
    $('#loading').show()
    
    /* Getting all the input into an object that we will pass to the backend as a parameter of the call*/
    variables = {};
    $('.form-control').each(function(index){
        variables[$(this).prop('id')] = $(this).val()
    });
    
    /* Call to the backend to run flow and get the output dataset */
    var flow_run =$.getJSON(getWebAppBackendUrl('run_scenario')+'/'+JSON.stringify(variables),function(data){
        console.log(data)
        /* modifying html to show the dataset as a table */
        $('#loading').hide()
        $('#df_table').append(data['data'])
        $('a').attr("href", data['link'])
        $('#df_table').show()
    })
    
}