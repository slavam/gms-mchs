class FoundAgroDecTelegram extends React.Component{
  constructor(props) {
    super(props);
  }
  render() {
    var desiredLink = "/agro_dec_observations/"+this.props.telegram.id;
    return (
      <tr>
        <td>{this.props.telegram.date.substr(0, 19)+' UTC'}</td>
        <td>{this.props.telegram.station_name}</td>
        <td><a href={desiredLink}>{this.props.telegram.telegram}</a></td>
      </tr>
    );
  }
}

class FoundAgroDecTelegrams extends React.Component{
  render() {
    var rows = [];
    this.props.telegrams.forEach((t) => {
      t.date = t.date.replace(/T/,' ');
      rows.push(<FoundAgroDecTelegram telegram={t} key={t.id}/>);
    });
    return (
      <table className="table table-hover">
        <thead>
          <tr>
            <th width="200px">Дата</th>
            <th>Метеостанция</th>
            <th>Текст</th>
          </tr>
        </thead>
        <tbody>{rows}</tbody>
      </table>
    );
  }
}

class SearchAgroDecTelegrams extends React.Component{
  constructor(props) {
    super(props);
    this.state = {
      telegrams: this.props.telegrams,
      errors: []
    };
    this.handleFormSubmit = this.handleFormSubmit.bind(this);
  }

  handleFormSubmit(params) {
    var that = this;
    var stationCode = params.stationCode == '0' ? '' : "&station_code="+params.stationCode;
    var text = params.text.length > 1 ? "&text="+params.text : '';
    $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "search_agro_dec_telegrams?date_from="+params.dateFrom+"&date_to="+params.dateTo+stationCode+text
      }).done(function(data) {
        that.setState({telegrams: data.telegrams, errors: []});
      }.bind(that))
      .fail(function(res) {
        that.setState({errors: ["Ошибка поиска"]});
      }.bind(that)); 
  }
  
  render(){
    return (
      <div>
        <h3>Параметры поиска</h3>
        <AgroSearchForm onFormSubmit={this.handleFormSubmit} dateFrom={this.props.dateFrom} dateTo={this.props.dateTo} errors={this.state.errors} stations={this.props.stations}/>
        <h3>Найденные телеграммы ({this.state.telegrams.length})</h3>
        <FoundAgroDecTelegrams telegrams={this.state.telegrams}/>
      </div>
    );
  }
}